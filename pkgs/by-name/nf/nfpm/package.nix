{
  stdenv,
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  buildPackages,
}:

buildGoModule rec {
  pname = "nfpm";
  version = "2.41.3";

  src = fetchFromGitHub {
    owner = "goreleaser";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-5pM3usXT3ukKkhKtDR5nIllaCCEUj7GVIl5HWq9DwII=";
  };

  vendorHash = "sha256-GnAo+B4UEZIf5K3d1XSU8WpHmdMqzO1nR0reSJ2D1Yk=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall =
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      ${emulator} $out/bin/nfpm man > nfpm.1
      installManPage ./nfpm.1
      installShellCompletion --cmd nfpm \
        --bash <(${emulator} $out/bin/nfpm completion bash) \
        --fish <(${emulator} $out/bin/nfpm completion fish) \
        --zsh  <(${emulator} $out/bin/nfpm completion zsh)
    '';

  meta = with lib; {
    description = "Simple deb and rpm packager written in Go";
    homepage = "https://github.com/goreleaser/nfpm";
    changelog = "https://github.com/goreleaser/nfpm/releases/tag/v${version}";
    maintainers = with maintainers; [
      techknowlogick
      caarlos0
    ];
    license = with licenses; [ mit ];
    mainProgram = "nfpm";
  };
}
