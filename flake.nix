{
  description = "Thorium using Nix Flake";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }: {
    packages.x86_64-linux =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        mkThorium = { pname, version, url, variant, hash }:
          let
            src = pkgs.fetchurl { inherit url hash; };
            appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
          in
          pkgs.appimageTools.wrapType2 {
            inherit pname version src;
            extraInstallCommands = ''
              install -m 444 -D ${appimageContents}/thorium-browser.desktop $out/share/applications/thorium-browser.desktop
              install -m 444 -D ${appimageContents}/thorium.png $out/share/icons/hicolor/512x512/apps/thorium.png
              substituteInPlace $out/share/applications/thorium-browser.desktop \
              --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
            '';
          };
      in
      {
        thorium-avx = mkThorium {
          pname = "thorium";
          version = "138.0.7204.300";
          variant = "AVX";
          url = "https://github.com/Alex313031/thorium/releases/download/M138.0.7204.300/Thorium_Browser_138.0.7204.300_AVX.AppImage";
          hash = "sha256-3FGMZKJnLJztZ2g6GGw2wvmrOMBfqHaJfaK6VvErhB0="; # Replace with the actual hash
        };
        thorium-avx2 = mkThorium {
          pname = "thorium";
          version = "138.0.7204.300";
          variant = "AVX2";
          url = "https://github.com/Alex313031/thorium/releases/download/M138.0.7204.300/Thorium_Browser_138.0.7204.300_AVX2.AppImage";
          hash = "sha256-vpAAoZv8Ayg1AN0Uo9Ou8fX22hdhJnxHM1W6XrpwMww=";
        };
        thorium-sse3 = mkThorium {
          pname = "thorium";
          version = "138.0.7204.300";
          variant = "SSE3";
          url = "https://github.com/Alex313031/thorium/releases/download/M138.0.7204.300/Thorium_Browser_138.0.7204.300_SSE3.AppImage";
          hash = "sha256-2aOHkc5SDVXgz7DHm1HaZa/7f4e3dyrPEs3/hQQOpCg=";
        };
        thorium-sse4 = mkThorium {
          pname = "thorium";
          version = "138.0.7204.300";
          variant = "SSE4";
          url = "https://github.com/Alex313031/thorium/releases/download/M138.0.7204.300/Thorium_Browser_138.0.7204.300_SSE4.AppImage";
          hash = "sha256-cr1yyiPYIh0JxLMlf0ZCt+Do0TYT6KvgYtM0ffknxVE=";
        };
      };

    apps.x86_64-linux =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; }; # Define pkgs here
        thoriumApp = variant: {
          type = "app";
          program = "${self.packages.x86_64-linux.${"thorium-" + variant}}/bin/thorium";
          meta = {
            description = "Thorium Browser (${variant}) - A fast and secure web browser";
            homepage = "https://thorium.rocks";
            license = pkgs.lib.licenses.bsd3;
            maintainers = with pkgs.lib.maintainers; [ Alex313031 ];
          };
        };
      in
      {
        thorium-avx = thoriumApp "avx";
        thorium-avx2 = thoriumApp "avx2";
        thorium-sse3 = thoriumApp "sse3";
        thorium-sse4 = thoriumApp "sse4";
      };
  };
}
