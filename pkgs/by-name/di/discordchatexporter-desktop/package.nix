{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  testers,
  discordchatexporter-desktop,
}:

buildDotnetModule rec {
  pname = "discordchatexporter-desktop";
  version = "2.43.3";

  src = fetchFromGitHub {
    owner = "tyrrrz";
    repo = "discordchatexporter";
    rev = version;
    hash = "sha256-r9bvTgqKQY605BoUlysSz4WJMxn2ibNh3EhoMYCfV3c=";
  };

  env.XDG_CONFIG_HOME = "$HOME/.config";

  projectFile = "DiscordChatExporter.Gui/DiscordChatExporter.Gui.csproj";
  nugetDeps = ./deps.nix;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  # I hate this. Gladly suggest improvements... dotnet format doesn't want to do it
  postPatch = ''
    substituteInPlace DiscordChatExporter.Gui/Services/SettingsService.cs \
      --replace-fail 'AppDomain.CurrentDomain.BaseDirectory, "Settings.dat"),' \
      '
                System.IO.Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
                    "discordchatexporter"
                ),
                "Settings.dat"
            ),'
  '';

  postFixup = ''
    ln -s $out/bin/DiscordChatExporter $out/bin/discordchatexporter
  '';

  passthru = {
    updateScript = ./updater.sh;
    tests.version = testers.testVersion {
      package = discordchatexporter-desktop;
      version = "v${version}";
    };
  };

  meta = with lib; {
    description = "Tool to export Discord chat logs to a file (GUI version)";
    homepage = "https://github.com/Tyrrrz/DiscordChatExporter";
    license = licenses.gpl3Plus;
    changelog = "https://github.com/Tyrrrz/DiscordChatExporter/blob/${version}/Changelog.md";
    maintainers = with maintainers; [ kekschen ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "discordchatexporter";
  };
}
