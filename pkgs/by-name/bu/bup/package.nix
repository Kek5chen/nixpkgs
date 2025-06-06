{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  perl,
  pandoc,
  python3,
  git,

  par2Support ? true,
  par2cmdline ? null,
}:

assert par2Support -> par2cmdline != null;

let
  version = "0.33.7";

  pythonDeps =
    with python3.pkgs;
    [
      setuptools
      tornado
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
      pyxattr
      pylibacl
      fuse
    ];
in

stdenv.mkDerivation {
  pname = "bup";
  inherit version;

  src = fetchFromGitHub {
    repo = "bup";
    owner = "bup";
    rev = version;
    hash = "sha256-tuOUml4gF4i7bE2xtjJJol1gRAfYv73RghUYwIDsGyM=";
  };

  buildInputs = [
    python3
  ];
  nativeBuildInputs = [
    pandoc
    perl
    makeWrapper
  ];

  configurePlatforms = [ ];

  postPatch = ''
    patchShebangs --build .
    substituteInPlace ./config/configure \
      --replace-fail 'bup_git=' 'bup_git="${lib.getExe git}" #'
  '';

  dontAddPrefix = true;

  makeFlags = [
    "MANDIR=$(out)/share/man"
    "DOCDIR=$(out)/share/doc/bup"
    "BINDIR=$(out)/bin"
    "LIBDIR=$(out)/lib/bup"
  ];

  env.BUP_PYTHON_CONFIG = lib.getExe' (lib.getDev python3) "python-config";
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=implicit-function-declaration -Wno-error=implicit-int";

  postInstall = ''
    wrapProgram $out/bin/bup \
      --prefix PATH : ${
        lib.makeBinPath [
          git
          par2cmdline
        ]
      } \
      --prefix NIX_PYTHONPATH : ${lib.makeSearchPathOutput "lib" python3.sitePackages pythonDeps}
  '';

  meta = with lib; {
    homepage = "https://github.com/bup/bup";
    description = "Efficient file backup system based on the git packfile format";
    mainProgram = "bup";
    license = licenses.gpl2Plus;

    longDescription = ''
      Highly efficient file backup system based on the git packfile format.
      Capable of doing *fast* incremental backups of virtual machine images.
    '';

    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ rnhmjoj ];
    # bespoke ./configure does not like cross
    broken = stdenv.buildPlatform != stdenv.hostPlatform;
  };
}
