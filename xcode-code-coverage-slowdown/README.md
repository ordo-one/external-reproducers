We have a SwiftUI Xcode project that imports quite a few SPM dependencies, it was noticed that the resulting binary was operating noticeably faster when using `Build -> For Profiling` over a release binary.
The resulting log was compared and it become clear that application built for release had additional `-profile-coverage-mapping -profile-generate` flags being added which slowed down the overall execution, even the project settings have code coverage turned off.

This affects Xcode from 14.3.1 to 15.1 Beta 3, and potentally earlier versions as well.

Conditions for reproducing:
1) Xcode project must use Swift Package Dependencies
2) Xcode project has to have tests defined, this will result in an automated created test plan that will have Code Coverage enabled for all targets by default; resulting in SPM packages being built with code coverage, including a release build.


```
git clone https://github.com/ordo-one/external-reproducers.git
cd external-reproducers
git checkout xcode-code-coverage-slowdown
cd xcode-code-coverage-slowdown
./xcodebuild.sh
```

Build without coverage by disabling coverage on the test plan:
```
cp BinaryTreeUI-coverage-off.xctestplan BinaryTreeUI.xctestplan
./xcodebuild.sh
```

The `build_log` file can be examined for the differences in compiler options after using either test plans. Code coming from SPM will be executing significantly slower.

The Test Plan has a default value of all targets, not just the tests:
![testplan-code-coverage-for-all-targets](https://github.com/ordo-one/external-reproducers/assets/103502659/0a53ab65-31e9-488d-a4c1-a423d6f9f1ff)

Additionally, a default code coverage being enabled causes the binaries to run significanly slower, in the example application run time increases to 6 seconds from 3 when Xcode project level code coverage for release build is turned on (default).

