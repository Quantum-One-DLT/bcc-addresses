############################################################################
#
# Hydra release jobset.
#
# The purpose of this file is to select jobs defined in default.nix and map
# them to all supported build platforms.
#
############################################################################

# The project sources
{ bcc-addresses ? { outPath = ./.; rev = "abcdef"; }

# Function arguments to pass to the project
, projectArgs ? {
    inherit sourcesOverride;
    config = { allowUnfree = false; inHydra = true; };
    gitrev = bcc-addresses.rev;
  }

# The systems that the jobset will be built for.
, supportedSystems ? [ "x86_64-linux" "x86_64-darwin" ]

# The systems used for cross-compiling (default: linux)
, supportedCrossSystems ? [ (builtins.head supportedSystems) ]

# A Hydra option
, scrubJobs ? true

, withProblematicWindowsTests ? false

# Dependencies overrides
, sourcesOverride ? {}

# Import pkgs, including The-Blockchain-Company common nix lib
, pkgs ? import ./nix { inherit sourcesOverride; }

}:

with (import pkgs.tbcoNix.release-lib) {
  inherit pkgs;
  inherit supportedSystems supportedCrossSystems scrubJobs projectArgs;
  packageSet = import bcc-addresses;
  gitrev = bcc-addresses.rev;
};

with pkgs.lib;

let
  # restrict supported systems to a subset where tests (if exist) are required to pass:
  testsSupportedSystems = intersectLists supportedSystems [ "x86_64-linux" "x86_64-darwin" ];
  # Recurse through an attrset, returning all derivations in a list matching test supported systems.
  collectJobs' = ds: filter (d: elem d.system testsSupportedSystems) (collect isDerivation ds);
  # Adds the package name to the derivations for windows-testing-bundle.nix
  # (passthru.identifier.name does not survive mapTestOn)
  collectJobs = ds: concatLists (
    mapAttrsToList (packageName: package:
      map (drv: drv // { inherit packageName; }) (collectJobs' package)
    ) ds);

  disabledMingwW64Tests = lib.optionalAttrs withProblematicWindowsTests {
    haskellPackages.Win32-network.checks.test-Win32-network = null;
    checks.tests.Win32-network.test-Win32-network = null;
    haskellPackages.network-mux.checks.test-network-mux = null;
    checks.tests.network-mux.test-network-mux = null;
  };

  # Remove build jobs for which cross compiling does not make sense.
  filterJobsCross = filterAttrs (n: _: n != "dockerImage" && n != "shell" && n != "checkCabalProject");

  inherit (systems.examples) mingwW64 musl64 ghcjs;

  jobs = {
    native = mapTestOn (packagePlatforms project);
    "${mingwW64.config}" = recursiveUpdate (mapTestOnCross mingwW64 (packagePlatformsCross (filterJobsCross project))) disabledMingwW64Tests;
    musl64 = mapTestOnCross musl64 (packagePlatformsCross (filterJobsCross project));
    ghcjs = mapTestOnCross ghcjs (packagePlatformsCross (filterJobsCross project));
  } // (mkRequiredJob (concatLists [
    (collectJobs jobs.musl64.checks)
    (collectJobs jobs."${mingwW64.config}".checks)
    (collectJobs jobs.ghcjs.checks)
    [ jobs.native.shell.x86_64-linux
      jobs.native.shell.x86_64-darwin
      jobs.musl64.bcc-address.x86_64-linux
      jobs."${mingwW64.config}".bcc-address.x86_64-linux
      jobs.ghcjs.library.x86_64-linux
    ]
  ]));

in jobs
