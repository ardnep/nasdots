{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation {
  pname = "ugreen-leds-kmod";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "miskcoo";
    repo = "ugreen_leds_controller";
    tag = "v0.3";
    hash = "sha256-eSTOUHs4y6n4cacpjQAp4JIfyu40aBJEMsvuCN6RFZc=";
  };

  sourceRoot = "source/kmod";

  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" "format" ];

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 led-ugreen.ko \
      "$out/lib/modules/${kernel.modDirVersion}/extra/led-ugreen.ko"

    runHook postInstall
  '';

  dontStrip = true;

  meta = {
    description = "UGREEN NAS front-panel LED kernel module";
    homepage = "https://github.com/miskcoo/ugreen_leds_controller";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
