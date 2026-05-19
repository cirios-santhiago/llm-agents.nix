{
  lib,
  stdenv,
  fetchurl,
  wrapBuddy,
  versionCheckHook,
  versionCheckHomeHook,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version urls hashes;

  platform = stdenv.hostPlatform.system;
in
stdenv.mkDerivation {
  pname = "antigravity";
  inherit version;

  src = fetchurl {
    url = urls.${platform} or (throw "Unsupported system: ${platform}");
    hash = hashes.${platform} or (throw "Unsupported system: ${platform}");
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ wrapBuddy ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm755 antigravity $out/bin/agy
    ln -s agy $out/bin/antigravity

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    versionCheckHomeHook
  ];

  passthru.category = "AI Coding Agents";

  meta = with lib; {
    description = "CLI for Google Antigravity, an agentic development platform";
    homepage = "https://antigravity.google/";
    changelog = "https://antigravity.google/cli";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ ];
    mainProgram = "agy";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
