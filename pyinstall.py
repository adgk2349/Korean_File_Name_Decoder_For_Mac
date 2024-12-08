import PyInstaller.__main__

from PyInstaller.utils.hooks import collect_submodules

PyInstaller.__main__.run([
    '--onefile',
    '--windowed',
    '--noconsole',
    '--collect-all=tkinterdnd2',
    'File_Name_Decoder_For_Mac.py',
    '--icon=File_Name_Decoder_For_Mac.icns'
])