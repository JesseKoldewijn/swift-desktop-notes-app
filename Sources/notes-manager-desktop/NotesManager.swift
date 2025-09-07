import Foundation

/// Structure representing a note with GUID-based identification
struct Note: Codable {
    let id: String
    var title: String
    var content: String
    let createdAt: Date
    var modifiedAt: Date
    
    init(title: String, content: String) {
        self.id = UUID().uuidString
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
    
    init(id: String, title: String, content: String, createdAt: Date) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = Date()
    }
}

/// Simple Notes Manager for file-based note storage with GUID-based identification
class NotesManager {
    private let notesDirectory: URL
    private let indexFile: URL
    private var notesIndex: [String: Note] = [:]
    
    init() {
        // Create notes directory in user's Documents folder
        let documentsPath = FileManager.default.urls(for: .documentDirectory, 
                                                    in: .userDomainMask).first ?? 
                          FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Documents")
        
        self.notesDirectory = documentsPath.appendingPathComponent("NotesManager")
        self.indexFile = notesDirectory.appendingPathComponent("notes_index.json")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: notesDirectory, 
                                               withIntermediateDirectories: true)
        print("📁 Notes directory: \(notesDirectory.path)")
        
        // Load existing notes index
        loadNotesIndex()  
    }
    
    
    /// Load the notes index from disk
    private func loadNotesIndex() {
        guard FileManager.default.fileExists(atPath: indexFile.path) else {
            print("📋 No existing notes index found")
            return
        }
        
        do {
            let data = try Data(contentsOf: indexFile)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let notes = try decoder.decode([Note].self, from: data)
            
            notesIndex = Dictionary(uniqueKeysWithValues: notes.map { ($0.id, $0) })
            print("📋 Loaded \(notesIndex.count) notes from index")
        } catch {
            print("❌ Error loading notes index: \(error)")
            notesIndex = [:]
        }
    }
    
    /// Save the notes index to disk
    private func saveNotesIndex() {
        do {
            let notes = Array(notesIndex.values).sorted { $0.title < $1.title }
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(notes)
            try data.write(to: indexFile)
            print("💾 Saved notes index with \(notes.count) notes")
        } catch {
            print("❌ Error saving notes index: \(error)")
        }
    }


    /// Create a new note or update existing note
    func saveNote(id: String? = nil, title: String, content: String) -> String? {
        let note: Note
        
        if let existingId = id, let existingNote = notesIndex[existingId] {
            // Update existing note
            note = Note(id: existingNote.id, 
                       title: title, 
                       content: content, 
                       createdAt: existingNote.createdAt)
        } else {
            // Create new note
            note = Note(title: title, content: content)
        }
        
        notesIndex[note.id] = note
        saveNotesIndex()
        
        print("💾 Saved note: \(note.title) (\(note.id))")
        return note.id
    }
    
    /// Load a note by ID
    func loadNote(id: String) -> Note? {
        let note = notesIndex[id]
        if let note = note {
            print("📖 Loaded note: \(note.title) (\(id))")
        } else {
            print("❌ Note not found: \(id)")
        }
        return note
    }
    
    /// Load a note by title (for backward compatibility)
    func loadNote(title: String) -> String? {
        // Find note by title
        if let note = notesIndex.values.first(where: { $0.title == title }) {
            print("📖 Loaded note by title: \(title) (\(note.id))")
            return note.content
        }
        print("❌ Note not found: \(title)")
        return nil
    }

    /// Get all notes with their IDs and titles
    func getAllNotesWithIds() -> [(id: String, title: String)] {
        let notes = Array(notesIndex.values)
            .sorted { $0.modifiedAt > $1.modifiedAt } // Most recently modified first
            .map { (id: $0.id, title: $0.title) }
        print("📝 Found \(notes.count) notes")
        return notes
    }
    
    /// Get all note titles (for backward compatibility)
    func getAllNotes() -> [String] {
        let titles = Array(notesIndex.values)
            .sorted { $0.modifiedAt > $1.modifiedAt }
            .map { $0.title }
        print("📝 Found \(titles.count) notes")
        return titles
    }
    
    /// Delete a note by ID
    func deleteNote(id: String) -> Bool {
        guard let note = notesIndex[id] else {
            print("❌ Note not found for deletion: \(id)")
            return false
        }
        
        notesIndex.removeValue(forKey: id)
        saveNotesIndex()
        print("🗑️ Deleted note: \(note.title) (\(id))")
        return true
    }
    
    /// Delete a note by title (for backward compatibility)
    func deleteNote(title: String) -> Bool {
        guard let note = notesIndex.values.first(where: { $0.title == title }) else {
            print("❌ Note not found for deletion: \(title)")
            return false
        }
        
        notesIndex.removeValue(forKey: note.id)
        saveNotesIndex()
        print("🗑️ Deleted note: \(title) (\(note.id))")
        return true
    }

    /// Check if a note exists by ID
    func noteExists(id: String) -> Bool {
        return notesIndex[id] != nil
    }
    
    /// Check if a note exists by title (for backward compatibility)
    func noteExists(title: String) -> Bool {
        return notesIndex.values.contains(where: { $0.title == title })
    }
    
    /// Find a note ID by title
    func findNoteId(byTitle title: String) -> String? {
        return notesIndex.values.first(where: { $0.title == title })?.id
    }
}
