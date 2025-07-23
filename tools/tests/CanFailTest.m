classdef CanFailTest <  matlab.unittest.TestCase
% BasicTest - Unit test for testing the openMINDS tutorials.


    methods (Test)
        function testToolboxDir(testCase)
            pathStr = matbox.toolboxdir();
            testCase.verifyClass(pathStr, 'char')
            if strcmp(getenv('TEST_SHOULD_FAIL'), 'true')
                testCase.verifyFalse(isfolder(pathStr))
            else
                testCase.verifyTrue(isfolder(pathStr))
            end
        end

        function testToolboxVersion(testCase)
            versionStr = matbox.toolboxversion();
            testCase.verifyClass(versionStr, 'char')
            if strcmp(getenv('TEST_SHOULD_FAIL'), 'true')
                testCase.verifyFalse(startsWith(versionStr, 'Version'))
            else
                testCase.verifyTrue(startsWith(versionStr, 'Version'))
            end
        end

        function testHelloWorld(testCase)
            hwStr = ghas.helloWorld();
            testCase.verifyClass(hwStr, 'string')
            if strcmp(getenv('TEST_SHOULD_FAIL'), 'true')
                testCase.verifyFalse(startsWith(hwStr, 'hello'))
            else
                testCase.verifyTrue(startsWith(hwStr, 'hello'))
            end
        end
    end
end
