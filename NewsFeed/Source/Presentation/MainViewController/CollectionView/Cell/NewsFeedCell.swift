import UIKit

/// Ячейка для коллекции главного экрана
final class NewsFeedCell: UICollectionViewCell {
    static let reuseId = Constants.reuseId

    private let thumbnail = UIImageView()
    private let titleLabel = UILabel()
    private let horizontalStack = UIStackView()

    /// Чтобы картинка не уехала в не свою ячейку при реюзе
    private var expectedIdentity: String?

    public var viewModel: NewsFeedCellViewModel? {
        didSet {
            expectedIdentity = viewModel?.id
            configure(with: viewModel)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
        expectedIdentity = nil
        titleLabel.text = nil
    }

    func setImage(_ image: UIImage?, ifMatches identity: String?) {
        guard expectedIdentity == identity else { return }
        thumbnail.image = image ?? UIImage(systemName: Constants.defaultImage)
    }

    // MARK: - Private

    private func commonInit() {
        configureUI()
        configureLayout()
    }

    private func configureUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.layer.masksToBounds = true

        thumbnail.contentMode = .scaleAspectFill
        thumbnail.clipsToBounds = true
        thumbnail.layer.cornerRadius = Constants.imageCornerRadius
        thumbnail.backgroundColor = .tertiarySystemFill
        thumbnail.translatesAutoresizingMaskIntoConstraints = false

        thumbnail.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        titleLabel.numberOfLines = Constants.titleMaxLines
        titleLabel.adjustsFontForContentSizeCategory = true

        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .center
        horizontalStack.spacing = Constants.stackSpacing

        horizontalStack.addArrangedSubview(thumbnail)
        horizontalStack.addArrangedSubview(titleLabel)

        contentView.addSubview(horizontalStack)
    }

    private func configureLayout() {
        let thumbWidthEq = thumbnail.widthAnchor.constraint(
            equalTo: contentView.widthAnchor,
            multiplier: Constants.thumbWidthMultiplier
        )
        thumbWidthEq.priority = .required

        let thumbAspect = thumbnail.heightAnchor.constraint(equalTo: thumbnail.widthAnchor)
        thumbAspect.priority = .defaultHigh // можно нарушить, если не влезает

        let thumbHeightClamp = thumbnail.heightAnchor.constraint(lessThanOrEqualTo: horizontalStack.heightAnchor)
        thumbHeightClamp.priority = .required

        let thumbMin = thumbnail.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.thumbMinWidth)
        thumbMin.priority = .defaultHigh

        NSLayoutConstraint.activate([
            thumbWidthEq,
            thumbAspect,
            thumbHeightClamp,
            thumbMin,
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.stackPaddingTop),
            horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.stackPaddingLeading),
            horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.stackPaddingTrailing),
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Constants.stackPaddingBottom),
        ])
    }

    private func configure(with viewModel: NewsFeedCellViewModel?) {
        guard let viewModel else { return }
        titleLabel.text = viewModel.title

        let isPad = traitCollection.horizontalSizeClass == .regular
        titleLabel.font = isPad
            ? .preferredFont(forTextStyle: .title2)
            : .preferredFont(forTextStyle: .subheadline)
    }
}

private extension NewsFeedCell {
    enum Constants {
        static let reuseId = "NewsCell"
        static let defaultImage = "photo"

        static let cornerRadius: CGFloat = 12
        static let imageCornerRadius: CGFloat = 8

        static let titleMaxLines = 2
        static let stackSpacing: CGFloat = 12

        static let thumbWidthMultiplier: CGFloat = 0.25
        static let thumbMinWidth: CGFloat = 60
        static let thumbMaxWidth: CGFloat = 160 // если нужен верхний лимит — делай его низкоприоритетным

        static let stackPaddingTop: CGFloat = 10
        static let stackPaddingLeading: CGFloat = 16
        static let stackPaddingTrailing: CGFloat = -10
        static let stackPaddingBottom: CGFloat = -10
    }
}
