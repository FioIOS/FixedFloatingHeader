//
//  CollectionDemoViewController.swift
//
// Copyright (c) 2020 Hunjong Bong
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import RxAppState

class CollectionDemoViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    private lazy var header = HeaderView()
    private var disposedBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.rx.viewDidLayoutSubviews
            .take(1)
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }

                // scrollView's frame size should fixed before add subView to it
                // so call setup() after viewDidLayoutSubviews
                strongSelf.setup()
            })
            .disposed(by: self.disposedBag)
    }

    private func setup() {
        // back button
        let backButton = UIButton()
        backButton.setTitle("back", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.backgroundColor = .gray
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(20)
        }
        backButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposedBag)

        // collectionView
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        view.insertSubview(collectionView, belowSubview: backButton)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        collectionView.register(MyCell.self, forCellWithReuseIdentifier: "MyCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.backgroundColor = .lightGray

        var insets = collectionView.scrollIndicatorInsets
        insets.top = header.maxHeight - ViewController.safeAreaTop
        collectionView.scrollIndicatorInsets = insets

        // header
        collectionView.addSubview(header)
        header.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(header.maxHeight)
            make.centerX.equalToSuperview()
        }

        // bind
        collectionView.rx.didScroll
            .bind(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }

                strongSelf.didScroll(strongSelf.collectionView)
            })
            .disposed(by: disposedBag)
    }

    private func didScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y

        if offsetY <= 0 {
            header.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(offsetY)
            }

            header.setHeight(header.maxHeight)
        } else if offsetY < (header.maxHeight - header.minHeight) {
            header.snp.updateConstraints { make in
                make.top.equalToSuperview()
            }

            header.setHeight(header.maxHeight - offsetY)
        } else {
            header.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(offsetY - (header.maxHeight - header.minHeight))
            }

            header.setHeight(header.minHeight)
        }
    }
}

extension CollectionDemoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: header.maxHeight, left: 8, bottom: 0, right: 8)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ceil((collectionView.frame.width - 8 * 3 ) / 2)
        return CGSize(width: width, height: 90)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

extension CollectionDemoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as? MyCell else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        }

        cell.bindData(indexPath.item)
        return cell
    }
}
