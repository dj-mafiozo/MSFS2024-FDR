"""Locate Delphi from explicit environment, PATH or Windows registration."""
import os,shutil
from pathlib import Path

def delphi_root():
 candidates=[os.environ.get('BDS')]
 compiler=shutil.which('dcc64.exe')
 if compiler:candidates.append(str(Path(compiler).parent.parent))
 if os.name=='nt':
  import winreg
  for hive in (winreg.HKEY_CURRENT_USER,winreg.HKEY_LOCAL_MACHINE):
   for base in (r'Software\Embarcadero\BDS',r'Software\WOW6432Node\Embarcadero\BDS'):
    try:
     with winreg.OpenKey(hive,base) as key:
      for i in range(winreg.QueryInfoKey(key)[0]):
       with winreg.OpenKey(key,winreg.EnumKey(key,i)) as version:
        try:candidates.append(winreg.QueryValueEx(version,'RootDir')[0])
        except OSError:pass
    except OSError:pass
 for candidate in candidates:
  if candidate and (Path(candidate)/'bin/dcc64.exe').is_file():return Path(candidate)
 raise RuntimeError('Delphi not found; set BDS or add dcc64.exe to PATH')
