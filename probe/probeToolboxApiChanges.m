% probeToolboxApiChanges - Probe toolbox packaging and install calls that MatBox makes
%
%   Each probe prints PASS, WARN (with the last warning) or ERROR (with the
%   error identifier and message), so the output can be compared across
%   MATLAB releases.

fprintf("MATLAB %s\n\n", version)

workFolder = fullfile(tempdir, "probe-toolbox");
if isfolder(workFolder)
    rmdir(workFolder, "s")
end
sourceFolder = fullfile(workFolder, "src");
mkdir(sourceFolder)
writelines(["function out = probeFunction()", "    out = 1;", "end"], ...
    fullfile(sourceFolder, "probeFunction.m"))
identifier = "2d1a6c3e-5b7f-4c9a-8e21-3f4b5a6c7d8e";

fprintf("== ToolboxOptions\n")
runProbe("Constructor with Description name-value", ...
    @() matlab.addons.toolbox.ToolboxOptions(sourceFolder, identifier, ...
        ToolboxName="Probe", Description="A description"))
runProbe("Set Description", @() setOption(sourceFolder, identifier, "Description", "A description"))
runProbe("Set ToolboxVersion to 0.11.0.1", @() setOption(sourceFolder, identifier, "ToolboxVersion", "0.11.0.1"))
runProbe("Set ToolboxVersion to 0.11.0+1", @() setOption(sourceFolder, identifier, "ToolboxVersion", "0.11.0+1"))
runProbe("Set SupportedPlatforms.Maci64", @() setMaci64(sourceFolder, identifier))
runProbe("Set RequiredAddons", @() setOption(sourceFolder, identifier, "RequiredAddons", requiredAddon()))
runProbe("Package with ToolboxVersion 0.11.0+1", ...
    @() packageWithVersion(sourceFolder, identifier, workFolder, "0.11.0+1"))

fprintf("\n== matlab.addons.install\n")
toolboxFile = packageForInstall(sourceFolder, identifier, workFolder);
runProbe("matlab.addons.install(file, true)", @() matlab.addons.install(toolboxFile, true))
runProbe("matlab.addons.install(file, false)", @() matlab.addons.install(toolboxFile, false))
runProbe("matlab.addons.install(file)", @() matlab.addons.install(toolboxFile))

function runProbe(name, probeFunction)
    lastwarn("")
    try
        probeFunction();
        [warningMessage, warningId] = lastwarn();
        if isempty(warningMessage)
            fprintf("PASS  %s\n", name)
        else
            fprintf("WARN  %s: [%s] %s\n", name, warningId, warningMessage)
        end
    catch ME
        fprintf("ERROR %s: [%s] %s\n", name, ME.identifier, ME.message)
    end
end

function opts = createOptions(sourceFolder, identifier)
    opts = matlab.addons.toolbox.ToolboxOptions(sourceFolder, identifier, ToolboxName="Probe");
end

function setOption(sourceFolder, identifier, name, value)
    opts = createOptions(sourceFolder, identifier);
    opts.(name) = value;
end

function setMaci64(sourceFolder, identifier)
    opts = createOptions(sourceFolder, identifier);
    opts.SupportedPlatforms.Maci64 = true;
end

function addon = requiredAddon()
    % Same fields as matbox.setup.internal.fex.getToolboxRequiredAddonStruct
    addon = struct( ...
        "Name", "Recursively list files and folders", ...
        "Identifier", "8a1c5f3e-2b4d-4e6f-9a0b-1c2d3e4f5a6b", ...
        "EarliestVersion", "earliest", ...
        "LatestVersion", "latest", ...
        "DownloadURL", "");
end

function packageWithVersion(sourceFolder, identifier, workFolder, versionNumber)
    opts = createOptions(sourceFolder, identifier);
    opts.ToolboxVersion = versionNumber;
    opts.OutputFile = fullfile(workFolder, "ProbeWithBuild.mltbx");
    matlab.addons.toolbox.packageToolbox(opts);
    fprintf("      toolboxVersion reads back %s\n", ...
        matlab.addons.toolbox.toolboxVersion(opts.OutputFile));
end

function toolboxFile = packageForInstall(sourceFolder, identifier, workFolder)
    opts = createOptions(sourceFolder, identifier);
    opts.ToolboxVersion = "1.2.3";
    % Include a license agreement where the release supports generating one
    if isprop(opts, "UseLicenseBSD")
        opts.UseLicenseBSD = true;
        fprintf("      packaging with a BSD license\n")
    end
    opts.OutputFile = fullfile(workFolder, "Probe.mltbx");
    matlab.addons.toolbox.packageToolbox(opts);
    toolboxFile = opts.OutputFile;
end
