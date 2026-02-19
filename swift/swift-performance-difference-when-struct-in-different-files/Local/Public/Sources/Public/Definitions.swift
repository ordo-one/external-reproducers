import Essentials

extension Namespace {
    public enum Definitions {
        public static let publicObject = PublicObject(
            description: // Some big description:
                """
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere, augue nec efficitur efficitur, nunc lectus convallis nisl, in rhoncus justo magna non ipsum. Sed dignissim, lorem ut lacinia condimentum, neque libero mollis nibh, vitae faucibus metus est a metus.

                Praesent non justo eu nisl fermentum pharetra. Donec consequat, ipsum sit amet tincidunt eleifend, velit est bibendum sem, sit amet ultrices nisl sapien sed nisi. Curabitur malesuada, odio nec pretium suscipit, orci neque porttitor risus, vitae sodales turpis sem non enim. Suspendisse potenti. Proin sagittis, lorem id fringilla accumsan, est augue laoreet purus, non pulvinar magna lorem at nisi.

                Aenean sit amet odio sed nisl tristique elementum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Vestibulum vitae arcu vel odio volutpat ultricies. Integer semper, neque ut tristique consequat, justo nulla blandit ex, sit amet pulvinar ipsum nisl vitae sem. Cras dictum, nisl et volutpat ultricies, neque nisi suscipit arcu, et semper dolor mauris vitae ipsum.

                Mauris commodo, mi sit amet ullamcorper bibendum, nulla nibh gravida urna, eget posuere risus lorem a arcu. Fusce id lectus leo. Pellentesque vitae efficitur arcu. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Quisque et magna id ante aliquet viverra. Nam at urna at nisi laoreet ullamcorper. Aliquam erat volutpat. Integer quis arcu ac ipsum aliquam facilisis.

                Phasellus non dui eget arcu sagittis fringilla. Sed sed diam vel ipsum pharetra convallis. Vivamus scelerisque, diam nec luctus pharetra, lorem sem elementum urna, vitae dignissim dolor odio vitae risus. Nulla facilisi. In hac habitasse platea dictumst. Ut at vehicula est. Etiam at nisi sit amet mi egestas elementum. Duis a purus ut libero iaculis feugiat. Integer id mauris a dolor aliquam eleifend quis eget urna.

                Nunc sed leo eget nunc tempus gravida. Cras at pellentesque risus, et convallis ex. Donec sed justo in augue consectetur pretium. Sed gravida turpis et urna interdum, vitae facilisis turpis vehicula. Pellentesque vel rutrum velit. Vivamus in dapibus lorem. Integer non dui ac erat ornare tristique. Nulla non quam et risus fermentum mattis. Vivamus sed libero sed justo pharetra tempus non vitae mauris.
                """
        )

        @frozen public struct PublicObjectNonCopyableInPlace: Sendable, ~Copyable {
            let publicObject: PublicObject

            init(_ publicObject: PublicObject) {
                self.publicObject = publicObject
            }

            public var value: FrozenStructure { publicObject.value }
        }

        public static let publicObjectNonCopyableInPlace = PublicObjectNonCopyableInPlace(publicObject)

        public static let publicObjectNonCopyableInOtherFile = PublicObjectNonCopyableInOtherFile(publicObject)

        public static let frozenStructure = publicObject.value

    }
}
