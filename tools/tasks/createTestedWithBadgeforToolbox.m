function createTestedWithBadgeforToolbox(versionNumber, projectRootDirectory)
%createTestedWithBadgesforToolbox - Take the test reports from the runs against
% multiple MATLAB releases, and generate the "Tested with" badge
%
%   Adapted from: https://github.com/mathworks/climatedatastore/tree/main/buildUtilities
    
    arguments
        versionNumber (1,1) string
        projectRootDirectory (1,1) string {mustBeFolder} = pwd
    end
    
    releasesTestedWith = "R2020a | R2024b";

    badgecolor = "orange";

    outputDirectory = fullfile(projectRootDirectory, '.github', 'badges', versionNumber);
    matbox.utility.writeBadgeJSONFile("tested with", releasesTestedWith, badgecolor,...
        "OutputFolder", outputDirectory)
end
