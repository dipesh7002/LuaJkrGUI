LibraryName = "jkrguiApp"
AppName = "JkrGUIApplication"
JkrGUIRepoPath = "C:/Users/sansk/OneDrive/Pictures/jkrgui"
NativeDirectory = "native/"
AndroidDirectory = "android/"
BuildType = "x64-debug"
Override = false


Jkr.BuildSystem.CreateLuaLibraryEnvironment(LibraryName, JkrGUIRepoPath, NativeDirectory, BuildType, Override)
Jkr.BuildSystem.CreateAndroidEnvironment(AppName, "android/", LibraryName, JkrGUIRepoPath)
