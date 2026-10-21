function installMltbx(agreeToLicense)
% installMltbx - Install a File Exchange .mltbx add-on and report the result
%
%   The add-on is "Recursively list files and folders" 1.0.4, which File
%   Exchange serves as an .mltbx file.

    url = "https://addons.mathworks.com/registry/v1/addons/packages/" + ...
        "d00d9727-fdd6-417d-9ee8-99c97b77eef5/1.0.4/-/download/mltbx";
    filePath = fullfile(tempdir, "recursively-list.mltbx");
    websave(filePath, url);

    fprintf("release: %s, agreeToLicense: %d\n", version("-release"), agreeToLicense);
    if isMATLABReleaseOlderThan("R2026b")
        installed = matlab.addons.install(filePath, agreeToLicense);
    else
        installed = matlab.addons.install(filePath);
    end
    disp(installed)
end
