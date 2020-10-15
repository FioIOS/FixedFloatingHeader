//
//  TableDemoViewController.swift
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

class TableDemoViewController: UIViewController {
    private var tableView: UITableView
    private lazy var header = HeaderView()
    private var disposedBag = DisposeBag()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        tableView = UITableView()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

        // tableView
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        view.insertSubview(tableView, belowSubview: backButton)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tableView.backgroundColor = .lightGray

        var insets = tableView.scrollIndicatorInsets
        insets.top = header.maxHeight - ViewController.safeAreaTop
        tableView.scrollIndicatorInsets = insets


        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: header.maxHeight)
        tableView.tableHeaderView = headerView

        // header
        tableView.addSubview(header)
        header.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(header.maxHeight)
            make.centerX.equalToSuperview()
        }

        // bind
        tableView.rx.didScroll
            .bind(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }

                strongSelf.didScroll(strongSelf.tableView)
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

extension TableDemoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TableDemoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        cell.textLabel?.text = "row: \(indexPath.row)"
        return cell
    }
}
