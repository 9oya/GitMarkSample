# GitMarkSample
Sample project with user's search and bookmark service using github open api.

## Description
GitMarkSample의 비즈니스 레이어는 ViewModel - ServiceLayer - ManagerLayer - Entity 로 설계되었습니다.
ViewModel에 mutable properties는 Observable Inputs/Ouputs을 제외하면 private으로 scope이 제한되어 있으며 그외에 외부 접근 가능한 properties는 immutable let constant로 선언되었습니다. table cell을 viewModel을 통해 data binding과 cell configuration이 되도록 했으며 여기서 CellConfigType이라는 cell viewModel의 confirm type을 하나로 만듦으로서 memento pattern과 같이 다양한 cell viewModel을 encoding하여 list형태로 저장하고 view로 decoding하여 table view에서 dequeue reuse하도록 했습니다.

## Future
비즈니스 레이어인 Services와 Managers는 protocol로 interface화되어 Mock class를 만들고 inject하여 stub된 데이터로 unit test를 용이하게 할 수 있습니다. testable하게 구현된 비즈니스 레이어에 unit test cases를 추가하여 test coverage를 높이고 코드를 검증할 수 있습니다.

## Frameworks
- UIKit
- RxSwift
- RxCocoa
- RxDataSource
- RxViewController
- Alamofire
- Kingfisher
- Snapkit
### For tests
- RxBlocking
- RxTest

## Architecture
- MVVM
