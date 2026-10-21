function reportDisplayState()
% reportDisplayState - Print what MATLAB reports about its display

    fprintf("release: %s\n", version("-release"));
    fprintf("DISPLAY: ""%s""\n", getenv("DISPLAY"));
    fprintf("batchStartupOptionUsed: %d\n", batchStartupOptionUsed);
    fprintf("usejava jvm: %d, awt: %d, desktop: %d\n", ...
        usejava("jvm"), usejava("awt"), usejava("desktop"));
    if usejava("jvm")
        fprintf("java.awt.GraphicsEnvironment.isHeadless: %d\n", ...
            java.awt.GraphicsEnvironment.isHeadless());
    end
end
