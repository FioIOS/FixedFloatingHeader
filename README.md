# FixedFloatingHeader


```
// in UITableView

let headerView = UIView()
headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: header.maxHeight)
tableView.tableHeaderView = headerView

tableView.addSubview(header)
header.snp.makeConstraints { make in
    make.top.equalToSuperview()
    make.width.equalToSuperview()
    make.height.equalTo(header.maxHeight)
    make.centerX.equalToSuperview()
}


// in UICollectionView
collectionView.addSubview(header)
header.snp.remakeConstraints { make in
    make.top.equalToSuperview()
    make.width.equalToSuperview()
    make.height.equalTo(header.maxHeight)
    make.centerX.equalToSuperview()
}

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: header.maxHeight, left: 8, bottom: 0, right: 8)
}
```



# ScreenShot
![image](https://github.com/drkong1/FixedFloatingHeader/blob/master/screen.gif)


# Library
SnapKit
https://github.com/SnapKit/SnapKit

RxSwift
https://github.com/ReactiveX/RxSwift

RxAppState
https://github.com/pixeldock/RxAppState
