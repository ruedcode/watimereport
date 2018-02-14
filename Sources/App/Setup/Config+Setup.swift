import LeafProvider
import FluentProvider
import MySQLProvider
import Foundation
import Jobs

extension Config {
    
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
        Jobs.oneoff(delay: 5.seconds) {
            print("I was delayed by 10 seconds.")
            let jobs = JobList()
            jobs.start()
        }
    }

    /// Configure providers
    private func setupProviders() throws {
        try addProvider(LeafProvider.Provider.self)
        try addProvider(Skype.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(FluentProvider.Provider.self)
    }
    
    private func setupPreparations() throws {
        preparations.append(Employee.self)
        preparations.append(Time.self)
    }
}
