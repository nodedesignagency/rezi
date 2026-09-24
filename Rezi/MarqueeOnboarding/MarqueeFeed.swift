import SwiftUI

extension JobCard {
    /// The four rows of the marquee screen, top to bottom.
    ///
    /// Figma repeats one card; this varies them on purpose, so the rows read as
    /// a live feed. The logos are the four real companies — Chase, NVIDIA,
    /// Meta, Samsung — with no two alike side by side, even where a row wraps.
    /// The scores span Fair, Good and Best so the gauges show all three
    /// colours. The first card of the top row is the one from the design.
    ///
    /// Five to a row is not arbitrary: a row has to be wider than the screen
    /// plus one card, so that a card leaving one edge can wrap round to the
    /// other out of sight. Titles stay short enough to fit the card on one line.
    static let marqueeRows: [[JobCard]] = [
        [
            JobCard(title: "Software Engineer", salary: "$250k-300k", location: "San Francisco, CA", score: 53, logoIndex: 0),
            JobCard(title: "ML Engineer", salary: "$280k-340k", location: "Santa Clara, CA", score: 88, logoIndex: 1),
            JobCard(title: "Product Designer", salary: "$180k-220k", location: "Menlo Park, CA", score: 74, logoIndex: 2),
            JobCard(title: "Hardware Engineer", salary: "$160k-200k", location: "Austin, TX", score: 46, logoIndex: 3),
            JobCard(title: "Brand Designer", salary: "$130k-160k", location: "Los Angeles, CA", score: 81, logoIndex: 2)
        ],
        [
            JobCard(title: "iOS Engineer", salary: "$210k-260k", location: "Remote, US", score: 67, logoIndex: 2),
            JobCard(title: "Data Analyst", salary: "$120k-150k", location: "New York, NY", score: 58, logoIndex: 0),
            JobCard(title: "UX Researcher", salary: "$150k-180k", location: "San Jose, CA", score: 35, logoIndex: 3),
            JobCard(title: "Backend Engineer", salary: "$190k-240k", location: "Seattle, WA", score: 92, logoIndex: 2),
            JobCard(title: "Data Scientist", salary: "$220k-270k", location: "Santa Clara, CA", score: 79, logoIndex: 1)
        ],
        [
            JobCard(title: "Product Manager", salary: "$190k-230k", location: "Chicago, IL", score: 62, logoIndex: 0),
            JobCard(title: "Frontend Engineer", salary: "$170k-210k", location: "Remote, US", score: 85, logoIndex: 1),
            JobCard(title: "Security Engineer", salary: "$200k-250k", location: "Menlo Park, CA", score: 49, logoIndex: 2),
            JobCard(title: "Research Scientist", salary: "$260k-320k", location: "Santa Clara, CA", score: 71, logoIndex: 1),
            JobCard(title: "Firmware Engineer", salary: "$150k-190k", location: "Austin, TX", score: 29, logoIndex: 3)
        ],
        [
            JobCard(title: "DevOps Engineer", salary: "$170k-210k", location: "Denver, CO", score: 56, logoIndex: 3),
            JobCard(title: "Solutions Architect", salary: "$210k-250k", location: "Santa Clara, CA", score: 64, logoIndex: 1),
            JobCard(title: "Content Designer", salary: "$140k-170k", location: "New York, NY", score: 77, logoIndex: 2),
            JobCard(title: "Quant Developer", salary: "$300k-380k", location: "New York, NY", score: 42, logoIndex: 0),
            JobCard(title: "Growth Marketer", salary: "$120k-150k", location: "Austin, TX", score: 90, logoIndex: 2)
        ]
    ]
}
