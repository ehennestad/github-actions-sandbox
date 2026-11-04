% probePackageReadme - Probe how the packager combines the Readme and Description properties
%
%   Packages a folder with one namespace function under several combinations
%   of the Description and Readme properties of
%   matlab.addons.toolbox.ToolboxOptions and of Markdown files in the folder.
%   For each package file it prints:
%     - files the packager added to the package folder
%     - "name", "summary" and "readme" of fsroot/resources/mpackage.json
%     - the entries at the root of fsroot
%     - every Markdown file in fsroot, with its text
%     - <description> of metadata/addonProperties.xml
%   It then installs one package file and prints what MATLAB reports for the
%   installed package. The package files are written to probe-output, which
%   the workflow uploads as an artifact.

fprintf("MATLAB %s\n", version)

outputFolder = fullfile(pwd, "probe-output");
if ~isfolder(outputFolder)
    mkdir(outputFolder)
end
workFolder = fullfile(tempdir, "probe-package-readme");
if isfolder(workFolder)
    rmdir(workFolder, "s")
end
mkdir(workFolder)

description = "DESCRIPTION TEXT. This sentence comes from the Description property.";
outsideReadme = fullfile(workFolder, "outside", "README.md");
writeMarkdownFile(outsideReadme, "readme-outside-package-folder", "../outside/README.md")

probeCases = [ ...
    newProbeCase("description-only", description, string.empty, "")
    newProbeCase("readme-and-description", description, "README.md", "README.md")
    newProbeCase("readme-elsewhere-and-description", description, "docs/overview.md", "docs/overview.md")
    newProbeCase("readme-without-description", "", "README.md", "README.md")
    newProbeCase("readme-file-without-option", description, "README.md", "")
    newProbeCase("readme-outside-package-folder", description, string.empty, outsideReadme)
    ];

identifiers = [ ...
    "0b6c1f3a-6e2d-4f1a-9c3b-1a2b3c4d5e01"
    "0b6c1f3a-6e2d-4f1a-9c3b-1a2b3c4d5e02"
    "0b6c1f3a-6e2d-4f1a-9c3b-1a2b3c4d5e03"
    "0b6c1f3a-6e2d-4f1a-9c3b-1a2b3c4d5e04"
    "0b6c1f3a-6e2d-4f1a-9c3b-1a2b3c4d5e05"
    "0b6c1f3a-6e2d-4f1a-9c3b-1a2b3c4d5e06"
    ];

for iCase = 1:numel(probeCases)
    runProbeCase(probeCases(iCase), identifiers(iCase), workFolder, outputFolder)
end

installPackage(fullfile(outputFolder, "readme-and-description.mltbx"))

function probeCase = newProbeCase(name, description, readmeFiles, readmeOption)
% newProbeCase - Describe one package to build
%
%   readmeFiles are the Markdown files to create, relative to the package
%   folder. readmeOption is the value for the Readme property: "" leaves it
%   unset, an absolute path is used as is, and a relative path is taken
%   relative to the package folder.

    probeCase = struct( ...
        "Name", name, ...
        "Description", description, ...
        "ReadmeFiles", readmeFiles, ...
        "ReadmeOption", readmeOption);
end

function runProbeCase(probeCase, identifier, workFolder, outputFolder)
    fprintf("\n== %s\n", probeCase.Name)
    fprintf("Description: ""%s""\n", probeCase.Description)

    packageFolder = fullfile(workFolder, probeCase.Name);
    namespaceFolder = fullfile(packageFolder, "+probereadme");
    mkdir(namespaceFolder)
    writelines(["function out = hello()", "    out = ""hello"";", "end"], ...
        fullfile(namespaceFolder, "hello.m"))
    for readmeFile = probeCase.ReadmeFiles
        writeMarkdownFile(fullfile(packageFolder, readmeFile), probeCase.Name, readmeFile)
    end
    filesBefore = listFiles(packageFolder);
    fprintf("Files in package folder: %s\n", strjoin(filesBefore, ", "))

    toolboxInfo = struct( ...
        "ToolboxName", "Probe " + probeCase.Name, ...
        "Summary", "SUMMARY TEXT of " + probeCase.Name, ...
        "Description", probeCase.Description);
    packageFile = fullfile(outputFolder, probeCase.Name + ".mltbx");

    lastwarn("")
    try
        opts = matlab.addons.toolbox.ToolboxOptions(packageFolder, identifier, toolboxInfo);
        if probeCase.ReadmeOption ~= ""
            if startsWith(probeCase.ReadmeOption, "/")
                opts.Readme = probeCase.ReadmeOption;
            else
                opts.Readme = fullfile(packageFolder, probeCase.ReadmeOption);
            end
            fprintf("Readme property: ""%s""\n", opts.Readme)
        else
            fprintf("Readme property: not set\n")
        end
        opts.ToolboxVersion = "1.0.0";
        opts.OutputFile = packageFile;
        matlab.addons.toolbox.packageToolbox(opts);
    catch ME
        fprintf("ERROR [%s] %s\n", ME.identifier, ME.message)
        return
    end
    [warningMessage, warningId] = lastwarn();
    if isempty(warningMessage)
        fprintf("PASS  packaged without warnings\n")
    else
        fprintf("WARN  packaged, last warning [%s] %s\n", warningId, warningMessage)
    end

    addedFiles = setdiff(listFiles(packageFolder), filesBefore);
    if isempty(addedFiles)
        fprintf("Files added to package folder: none\n")
    else
        fprintf("Files added to package folder: %s\n", strjoin(addedFiles, ", "))
    end

    printPackageContents(packageFile, fullfile(workFolder, probeCase.Name + "-unzipped"))
end

function writeMarkdownFile(filePath, caseName, relativePath)
    parentFolder = fileparts(filePath);
    if ~isfolder(parentFolder)
        mkdir(parentFolder)
    end
    writelines([ ...
        "# README FILE TEXT", ...
        "", ...
        "Written for case " + caseName + " as " + relativePath + ".", ...
        "", ...
        "[A link](https://example.com)"], filePath)
end

function relativePaths = listFiles(folder)
    listing = dir(fullfile(folder, "**", "*"));
    listing = listing(~[listing.isdir]);
    absolutePaths = string(fullfile({listing.folder}, {listing.name}));
    relativePaths = sort(erase(absolutePaths, folder + filesep));
end

function printPackageContents(packageFile, extractFolder)
    unzip(packageFile, extractFolder);
    rootFolder = fullfile(extractFolder, "fsroot");

    mpackageFile = fullfile(rootFolder, "resources", "mpackage.json");
    if isfile(mpackageFile)
        mpackage = jsondecode(fileread(mpackageFile));
        for fieldName = ["name", "summary", "readme"]
            fprintf("mpackage.json %s: %s\n", fieldName, describeField(mpackage, fieldName))
        end
    else
        fprintf("mpackage.json: not in package file\n")
    end

    rootListing = dir(rootFolder);
    rootEntries = setdiff(string({rootListing.name}), [".", ".."]);
    fprintf("fsroot entries: %s\n", strjoin(rootEntries, ", "))

    markdownListing = dir(fullfile(rootFolder, "**", "*.md"));
    if isempty(markdownListing)
        fprintf("Markdown files in fsroot: none\n")
    end
    for iFile = 1:numel(markdownListing)
        filePath = fullfile(markdownListing(iFile).folder, markdownListing(iFile).name);
        fprintf("Markdown file %s:\n", erase(filePath, rootFolder + filesep))
        fprintf("    | %s\n", readlines(filePath))
    end

    addonPropertiesFile = fullfile(extractFolder, "metadata", "addonProperties.xml");
    try
        addonProperties = readstruct(addonPropertiesFile, FileType="xml");
        fprintf("addonProperties.xml description: %s\n", describeField(addonProperties, "description"))
    catch ME
        fprintf("addonProperties.xml: [%s] %s\n", ME.identifier, ME.message)
    end
end

function text = describeField(s, fieldName)
    if ~isfield(s, fieldName)
        text = "<field absent>";
    elseif isempty(s.(fieldName)) || all(ismissing(s.(fieldName)))
        text = "<empty>";
    else
        text = """" + strjoin(string(s.(fieldName)), newline) + """";
    end
end

function installPackage(packageFile)
    fprintf("\n== install %s\n", packageFile)
    try
        installedAddon = matlab.addons.install(packageFile);
        disp(installedAddon)
    catch ME
        fprintf("ERROR install: [%s] %s\n", ME.identifier, ME.message)
        return
    end
    fprintf("which probereadme.hello: ""%s""\n", which("probereadme.hello"))

    try
        installedPackages = mpmlist();
        fprintf("mpmlist returns %s\n", class(installedPackages))
        disp(installedPackages)
        for iPackage = 1:numel(installedPackages)
            if contains(string(installedPackages(iPackage).Name), "probe", IgnoreCase=true)
                disp(installedPackages(iPackage))
            end
        end
    catch ME
        fprintf("ERROR mpmlist: [%s] %s\n", ME.identifier, ME.message)
    end
end
