{ lib, stdenv, ugreen-leds-cli }:

stdenv.mkDerivation {
  pname = "ugreen-leds-activity";
  version = ugreen-leds-cli.version;

  # Reuse the complete, pinned upstream source archive.
  src = ugreen-leds-cli.src;

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    $CXX -std=c++17 -O2 -pthread \
      scripts/blink-disk.cpp \
      -o ugreen-blink-disk

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 ugreen-blink-disk \
      "$out/bin/ugreen-blink-disk"

    runHook postInstall
  '';

  meta = {
    description = "UGREEN disk-activity LED monitoring helper";
    homepage = "https://github.com/miskcoo/ugreen_leds_controller";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "ugreen-blink-disk";
  };
}
