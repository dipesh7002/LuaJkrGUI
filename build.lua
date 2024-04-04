LibraryName = "jkrguiApp"
JkrGUIRepoPath = "C:/Users/sansk/OneDrive/Pictures/jkrgui"
NativeFolder = "native/" -- Where native C++ files are to be generated
BuildType = "x64-debug"



Jkr.BuildSystem.CreateLuaLibraryEnvironment(LibraryName, JkrGUIRepoPath, NativeFolder, BuildType, false)
