function testToolbox(varargin)
    installMatBox()
    projectRootDir = ghas.projectdir();
    matbox.tasks.testToolbox(projectRootDir, varargin{:})
end
