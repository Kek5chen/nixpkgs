{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "linuxpy";
  version = "0.20.0";

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-mNWmzl52GEZUEL3q8cP59qxMduG1ijgsvGoD5ddSG94=";
  };

  pythonImportsCheck = [ "linuxpy" ];

  meta = with lib; {
    description = "Human friendly interface to linux subsystems using python";
    homepage = "https://github.com/tiagocoutinho/linuxpy";
    license = licenses.gpl3Only;
    maintainers = with lib.maintainers; [ kekschen ];
  };
}
