//
//  HeaderView.swift
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

struct HeaderModel {
    enum HeaderType {
        case fixed
        case floating
    }

    fileprivate var type: HeaderType
    fileprivate var height: CGFloat
    fileprivate var color: UIColor
}

class HeaderView: UIView {
    private var models: [HeaderModel]
    private var headers: [UIView]

    public var maxHeight: CGFloat {
        // sum of all
        return 150
    }

    public var minHeight: CGFloat {
        // sum of .fixed
        return 100
    }

    override init(frame: CGRect) {
        let model1 = HeaderModel(type: .fixed, height: 100, color: .yellow)
        let model2 = HeaderModel(type: .floating, height: 50, color: .cyan)

        models = [model1, model2]
        headers = []
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        var bottom: CGFloat = 0
        for model in models.reversed() {
            let view = UIView()
            view.backgroundColor = model.color
            addSubview(view)

            view.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(model.height)
                make.bottom.equalToSuperview().offset(-bottom)
            }
            bottom += model.height

            headers.append(view)

            let label = UILabel()
            label.text = model.type == .fixed ? "This is a fixed header" : "This is a floating header"
            label.textColor = .black
            view.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerY.trailing.equalToSuperview()
            }
        }
    }

    public func setHeight(_ height: CGFloat) {
        guard let view = headers.last else { return }

        view.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(-height + 100)
        }
    }
}
