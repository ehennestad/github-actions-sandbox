classdef HelloWorldTest <  matlab.unittest.TestCase
% BasicTest - Unit test for testing the openMINDS tutorials.


    methods (Test)
        function testToolboxDir(testCase)
            pathStr = matbox.toolboxdir();
            testCase.verifyClass(pathStr, 'char')
            testCase.verifyTrue(isfolder(pathStr))
        end

        function testToolboxVersion(testCase)
            versionStr = matbox.toolboxversion();
            testCase.verifyClass(versionStr, 'char')
            testCase.verifyTrue(startsWith(versionStr, 'Version'))
        end

        function testHelloWorld(testCase)
            hwStr = ghas.helloWorld();
            testCase.verifyClass(hwStr, 'string')
            testCase.verifyTrue(startsWith(hwStr, 'hello'))
        end
    end
end
