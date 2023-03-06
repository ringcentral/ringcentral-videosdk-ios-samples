//
//  RCVMeetingGalleryViewController.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//
import UIKit
import rcvsdk
import AVFoundation


protocol GalleryViewControllerDelegate: AnyObject {
    func didOpen(participant: RcvIParticipant?, from cell: RCVParticipantsListCell)
}

class MeetingGalleryViewLayout: UICollectionViewFlowLayout {
    public var isFirst: Bool = false
    public var lineSpacing: CGFloat = 2.0
    public var interitemSpacing: CGFloat = 2.0
    public var maxNumberOfItems: Int = 3
    fileprivate var bloomScale: CGFloat = 1.05

    public enum JustifyContent {
        case start, end, center, spaceBetween, spaceAround
    }

    public enum AlignItem {
        case start, end, center, stretch
    }

    public var alignContent: JustifyContent = .start
    public var justifyContent: JustifyContent = .start
    public var alignItems: AlignItem = .start

    private var frames: [CGRect] = []

    override func prepare() {
        super.prepare()

        guard let cv = collectionView else {
            return
        }
        let totalNum = cv.numberOfItems(inSection: 0)
        frames = galleryViewLayout(with: totalNum)
    }
    
    override var collectionViewContentSize: CGSize {
        return collectionView?.bounds.size ?? .zero
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let oldBounds = collectionView?.bounds, oldBounds != newBounds {
            return true
        }
        if isFirst && collectionView?.numberOfItems(inSection: 0) != frames.count {
            return true
        }
        return false
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attrs = super.layoutAttributesForElements(in: rect) else { return nil }
        for (attr, frame) in zip(attrs, frames) {
            attr.frame = frame
        }
        return attrs
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attrs = super.layoutAttributesForItem(at: indexPath)
        guard indexPath.item < frames.count else {
            return attrs
        }
        attrs?.frame = frames[indexPath.item]
        return attrs
    }
    
    static func getDisplaySize(_ collectionView: UIView?) -> (CGSize, UIEdgeInsets) {
        guard let cv = collectionView else {
            return (CGSize.zero, UIEdgeInsets.zero)
        }
        let viewSize: CGSize
        let safeInset: UIEdgeInsets
        let pageControlHeight: CGFloat = 30.0
        let margin = 16.0
        if var inset = UIApplication.shared.keyWindow?.safeAreaInsets {
            inset.right = max(inset.left, inset.right)
            inset.right = max(inset.right, margin)
            inset.left = inset.right
            inset.top = inset.top == 20 ? inset.top + margin : max(inset.top, margin)
            inset.bottom = max(pageControlHeight, inset.bottom)
            inset.bottom = max(inset.bottom, margin)
            safeInset = inset
            viewSize = cv.bounds.inset(by: inset).size
        } else {
            viewSize = cv.bounds.size
            safeInset = UIEdgeInsets(top: margin, left: margin, bottom: pageControlHeight, right: margin)
        }
        return (viewSize, safeInset)
    }
}


extension MeetingGalleryViewLayout {
    private func galleryViewSingleFullscreenCellLayout() -> [CGRect] {
        return [collectionView?.bounds ?? .zero]
    }

    private func galleryViewLayout(with count: Int) -> [CGRect] {
        var frames: [CGRect] = []
        let (viewSize, safeInset) = MeetingGalleryViewLayout.getDisplaySize(collectionView)
        let cellSize = getCellSize(viewSize: viewSize, count: count)

        let (totalHeight, lineData) = distributeLines(size: cellSize, maxWidth: viewSize.width, count: count)

        var (yOffset, verticalSpacing) = distribute(justifyContent: .center,
                                                    maxPrimary: viewSize.height,
                                                    totalPrimary: totalHeight,
                                                    minimunSpacing: lineSpacing,
                                                    numberOfItems: lineData.count)
        yOffset += safeInset.top

        for (lineSize, itemCount) in lineData {
            let (xOffset, horizontalSpacing) = distribute(justifyContent: .center,
                                                          maxPrimary: viewSize.width,
                                                          totalPrimary: lineSize.width,
                                                          minimunSpacing: interitemSpacing,
                                                          numberOfItems: itemCount)

            let startOffset = CGPoint(x: xOffset + safeInset.left, y: yOffset)
            let lineFrames = alignItem(cellSize: cellSize, startOffset: startOffset, spacing: horizontalSpacing, count: itemCount)

            frames.append(contentsOf: lineFrames)

            yOffset += lineSize.height + verticalSpacing
        }
        return frames
    }

    @objc fileprivate func getCellSize(viewSize: CGSize, count: Int) -> CGSize {
        let ratio: CGFloat = 16.0 / 9.0
        let itemSize: CGSize

        assert(bloomScale >= 1.0, "bloomScale must greaer than 1.0")
        func distribute(_ length: CGFloat, _ count: CGFloat, _ spacing: CGFloat) -> CGFloat {
            return (length - spacing * (count - 1.0)) / (count + bloomScale - 1)
        }

        if count > 4 {
            let isPortrait = viewSize.height * 0.88 > viewSize.width // 16*2/9*4 = 0.88
            if isPortrait {
                switch count {
                case 5..<9:
                    itemSize = CGSize(width: distribute(viewSize.width, 2.0, interitemSpacing),
                                      height: distribute(viewSize.height, 4.0, lineSpacing))
                default:
                    itemSize = CGSize(width: distribute(viewSize.width, 3.0, interitemSpacing),
                                      height: distribute(viewSize.height, 5.0, lineSpacing))
                }
            } else {
                switch count {
                case 5..<7:
                    itemSize = CGSize(width: distribute(viewSize.width, 3.0, interitemSpacing),
                                      height: distribute(viewSize.height, 2.0, lineSpacing))
                case 7..<10:
                    itemSize = CGSize(width: distribute(viewSize.width, 3.0, interitemSpacing),
                                      height: distribute(viewSize.height, 3.0, lineSpacing))
                default:
                    itemSize = CGSize(width: distribute(viewSize.width, 4.0, interitemSpacing),
                                      height: distribute(viewSize.height, 4.0, lineSpacing))
                }
            }
        } else {
            let isPortrait = viewSize.height > viewSize.width
            if isPortrait {
                itemSize = CGSize(width: distribute(viewSize.width, 1.0, interitemSpacing),
                                  height: distribute(viewSize.height, CGFloat(count), lineSpacing))
            } else {
                switch count {
                case 2:
                    itemSize = CGSize(width: distribute(viewSize.width, 2.0, interitemSpacing),
                                      height: distribute(viewSize.width, 1.0, interitemSpacing))
                case 3, 4:
                    itemSize = CGSize(width: distribute(viewSize.width, 2.0, interitemSpacing),
                                      height: distribute(viewSize.height, 2.0, lineSpacing))
                default:
                    itemSize = viewSize
                }
            }
        }

        if itemSize.width > itemSize.height * ratio {
            return CGSize(width: floor(itemSize.height * ratio), height: floor(itemSize.height))
        } else {
            return CGSize(width: floor(itemSize.width), height: floor(itemSize.width / ratio))
        }
    }

    private func distributeLines(size: CGSize, maxWidth: CGFloat, count: Int) ->
        (totalHeight: CGFloat, lineData: [(lineSize: CGSize, count: Int)]) {
        var lineData: [(lineSize: CGSize, count: Int)] = []
        var currentLineItemCount = 0
        var currentLineWidth: CGFloat = 0
        var currentLineMaxHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        for _ in 0..<count {
            if currentLineWidth + size.width > maxWidth, currentLineItemCount != 0 {
                lineData.append((lineSize: CGSize(width: currentLineWidth - CGFloat(currentLineItemCount) * interitemSpacing,
                                                  height: currentLineMaxHeight),
                                 count: currentLineItemCount))
                totalHeight += currentLineMaxHeight
                currentLineMaxHeight = 0
                currentLineWidth = 0
                currentLineItemCount = 0
            }
            currentLineMaxHeight = max(currentLineMaxHeight, size.height)
            currentLineWidth += size.width + interitemSpacing
            currentLineItemCount += 1
        }
        if currentLineItemCount > 0 {
            lineData.append((lineSize: CGSize(width: currentLineWidth - CGFloat(currentLineItemCount) * interitemSpacing,
                                              height: currentLineMaxHeight),
                             count: currentLineItemCount))
            totalHeight += currentLineMaxHeight
        }
        return (totalHeight, lineData)
    }

    private func alignItem(cellSize: CGSize,
                           startOffset: CGPoint,
                           spacing: CGFloat,
                           count: Int) -> [CGRect] {
        var frames: [CGRect] = []
        var offsetX = startOffset.x
        let offsetY = startOffset.y
        for _ in 0..<count {
            let cellFrame = CGRect(origin: CGPoint(x: offsetX, y: offsetY), size: cellSize)
            frames.append(cellFrame)
            offsetX += cellSize.width + spacing
        }
        return frames
    }

    private func distribute(justifyContent: JustifyContent,
                            maxPrimary: CGFloat,
                            totalPrimary: CGFloat,
                            minimunSpacing: CGFloat,
                            numberOfItems: Int) -> (offset: CGFloat, spacing: CGFloat) {
        var offset: CGFloat = 0
        var spacing = minimunSpacing
        guard numberOfItems > 0 else { return (offset, spacing) }
        if totalPrimary + CGFloat(numberOfItems - 1) * minimunSpacing < maxPrimary {
            let leftOverPrimary = maxPrimary - totalPrimary
            switch justifyContent {
            case .start:
                break
            case .center:
                offset += (leftOverPrimary - minimunSpacing * CGFloat(numberOfItems - 1)) / 2
            case .end:
                offset += (leftOverPrimary - minimunSpacing * CGFloat(numberOfItems - 1))
            case .spaceBetween:
                guard numberOfItems > 1 else { break }
                spacing = leftOverPrimary / CGFloat(numberOfItems - 1)
            case .spaceAround:
                spacing = leftOverPrimary / CGFloat(numberOfItems)
                offset = spacing / 2
            }
        }
        return (offset, spacing)
    }

}


class RCVMeetingGalleryViewController: UIViewController {
    private var cells: [String] = ["cell1", "cell2", "cell3", "cell4", "cell5", "cell6", "cell7", "cell8", "cell9", "cell10", "cell11", "cell12", "cell13", "cell14", "cell15", "cell16"]
    private var isFirst = false
    private(set) var pageIndex: Int = 0
    public var maxParticipants: Int = 3 {
        didSet {
            if flowLayout.maxNumberOfItems != maxParticipants {
                flowLayout.maxNumberOfItems = maxParticipants
            }
        }
    }
    private weak var delegate: GalleryViewControllerDelegate?
    private var selfPreviewIdentifier = "camera"
    public var participants: [RcvIParticipant] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public var videoCanvasDict = Dictionary<Int64, RCVideoCanvas>()
    
    lazy var flowLayout: MeetingGalleryViewLayout = {
        var flowlayout = MeetingGalleryViewLayout()
        flowlayout.isFirst = self.isFirst
        flowlayout.maxNumberOfItems = self.maxParticipants
        return flowlayout
    }()
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = false
        cells.forEach { identifier in
            cv.register(RCVParticipantsListCell.self, forCellWithReuseIdentifier: identifier)
        }
        cv.register(RCVParticipantsListCell.self, forCellWithReuseIdentifier: selfPreviewIdentifier)

        cv.accessibilityIdentifier = "statusCollectionView"
        cv.backgroundColor = UIColor.clear
        cv.isScrollEnabled = false
        cv.contentInsetAdjustmentBehavior = .never
        return cv
    }()
    
    required init(withDelegate delegate: GalleryViewControllerDelegate?,
                  isFirst: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.isFirst = isFirst
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.makeConstraintsToBindToSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didUpdateCellStatus()
        
        let authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if(authStatus == AVAuthorizationStatus.denied || authStatus == AVAuthorizationStatus.restricted) {
            return
        }
    }
    
    public func updatePage(_ current: Int, total: Int) {
        pageIndex = current
    }
    
    func didUpdateCellStatus(){
        
    }
}


extension RCVMeetingGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let participant = participants[indexPath.item]
        let cell: RCVParticipantsListCell
        
        let identifier = cells[indexPath.item]
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! RCVParticipantsListCell
        videoCanvasDict[participant.getModelId()]?.attach(cell.getVideoView())
        cell.update(user: participant)
        return cell
    }
}
