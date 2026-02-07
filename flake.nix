{
  description = "appium-nix: reproducible Appium runtime using Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in {

      devShells = nixpkgs.lib.genAttrs allSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          installInspector = builtins.getEnv "INSTALL_APPIUM_INSPECTOR" == "1";

          androidCmdlineTools = pkgs.fetchzip {
            name = "android-commandlinetools";
            url = "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip";
            hash = "sha256-NjxJzHRT2/zZ9YzzjqaMVxpOELkDneQgc1/y1GUnZow=";
          };

          appiumInspector =
            if installInspector && pkgs.stdenv.isLinux then
              pkgs.appimageTools.wrapType2 {
                name = "appium-inspector";
                src = pkgs.fetchurl {
                  url = "https://github.com/appium/appium-inspector/releases/download/v2024.3.4/Appium-Inspector-2024.3.4-linux-x86_64.AppImage";
                  hash = "sha256-rLDne7F9OvIFZGKzAT3ZvogfepWTwh9l5XMQ1Fh6ADQ=";
                };
              }
            else null;

          python = pkgs.python311;
        in {
          default = pkgs.mkShell {
            nativeBuildInputs =
              [ pkgs.nodejs pkgs.jdk17 ]
              ++ pkgs.lib.optional installInspector pkgs.appimage-run;

            packages = [
              (python.withPackages (ps: with ps; [
                pytest
                selenium
                appium-python-client
              ]))
            ];

            shellHook = ''
              export JAVA_HOME=${pkgs.jdk17}
              export ANDROID_HOME="$PWD/.android-sdk"
              export ANDROID_SDK_ROOT="$ANDROID_HOME"
              export PATH="$ANDROID_HOME/platform-tools:$PATH"

              mkdir -p "$ANDROID_HOME/cmdline-tools/latest"
              if [ ! -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
                cp -r ${androidCmdlineTools}/* "$ANDROID_HOME/cmdline-tools/latest/"
              fi

              "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$ANDROID_HOME" "platform-tools"
              "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$ANDROID_HOME" "build-tools;34.0.0"

              if [ ! -d node_modules ]; then
                npm install appium
              fi

              export PATH="$PWD/node_modules/.bin:$PATH"

              INSTALLED_DRIVERS="$(appium driver list --installed --json 2>/dev/null || true)"

              echo "$INSTALLED_DRIVERS" | grep -q '"uiautomator2"' || appium driver install uiautomator2
              echo "$INSTALLED_DRIVERS" | grep -q '"chromium"' || appium driver install chromium
            ''
            + pkgs.lib.optionalString installInspector ''
              ln -sf ${appiumInspector}/bin/* .
            ''
            + ''
              echo ""
              echo "📦 appium-nix environment ready"
              echo ""
            '';
          };
        });

      apps = nixpkgs.lib.genAttrs allSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = {
            type = "app";
            program = "${pkgs.writeShellScript "appium-nix-run" ''
            echo "[appium-nix] Ready"

              exec nix develop . --command bash -c '

                export PATH="$PWD/node_modules/.bin:$PATH"

                if [ $# -eq 0 ]; then
                echo "[appium-nix] Starting Appium server..."
                exec appium
                fi

                SCRIPT="$1"

                echo "[appium-nix] Starting Appium..."
                appium > .appium.log 2>&1 &
                APPIUM_PID=$!

                echo "[appium-nix] Waiting for server (4723)..."
                command -v nc >/dev/null && {
                  for i in $(seq 1 30); do
                    nc -z 127.0.0.1 4723 && break
                    sleep 1
                  done
                }

                echo "[appium-nix] Running: $SCRIPT"
                python "$SCRIPT"
                STATUS=$?

                echo "[appium-nix] Stopping Appium..."
                kill $APPIUM_PID 2>/dev/null || true

                exit $STATUS
              ' -- "$@"
            ''}";
          };
        });
    };
}
