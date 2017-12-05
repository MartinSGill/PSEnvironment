# this is a Pester test file

#region Further Reading
# http://www.powershellmagazine.com/2014/03/27/testing-your-powershell-scripts-with-pester-assertions-and-more/
#endregion
#region LoadScript
# load the script file into memory
# attention: make sure the script only contains function definitions
# and no active code. The entire script will be executed to load
# all functions into memory
Import-Module (Join-Path $PSScriptRoot PSEnvironment.psm1) -Force
#endregion

InModuleScope PSEnvironment {
  Describe 'Test-EnvironmentPath' {
    Context 'Path in environment' {
      Mock Get-EnvironmentPath { @{ path = 'c:\path1\path1\' }, @{ path = 'c:\path2\path2\' }  }
      It 'returns true' {
        Test-EnvironmentPath -path 'c:\path1\path1'
      }
    }

    Context 'Path not in environment' {
      Mock Get-EnvironmentPath { @{ path = 'c:\path1\path1\' }, @{ path = 'c:\path2\path2\' }  }
      It 'returns false' {
        Test-EnvironmentPath -path 'c:\path3\path3'
      }
    }

  }
}
