import CGtk
import Foundation

// Simple GTK4 Notes Manager Application

// Global variables to hold references
nonisolated(unsafe) var currentNoteId: String = ""
nonisolated(unsafe) var notesManager = NotesManager()
nonisolated(unsafe) var titleEntry: UnsafeMutablePointer<GtkWidget>?
nonisolated(unsafe) var textBuffer: UnsafeMutablePointer<GtkTextBuffer>?
nonisolated(unsafe) var notesListBox: UnsafeMutablePointer<GtkWidget>?

// Initialize GTK
gtk_init()

// Create the application
let app = gtk_application_new("com.example.notesmanager", G_APPLICATION_DEFAULT_FLAGS)

// Button callback functions
nonisolated(unsafe) let newNoteCallback: @convention(c) (UnsafeMutablePointer<GtkButton>?, gpointer?) -> Void = { button, userData in
    // Clear current selection
    currentNoteId = ""
    gtk_entry_set_text_wrapper(gtk_entry_cast(titleEntry), "New Note")
    gtk_text_buffer_set_text(textBuffer, "", -1)
}

nonisolated(unsafe) let saveNoteCallback: @convention(c) (UnsafeMutablePointer<GtkButton>?, gpointer?) -> Void = { button, userData in
    let title = String(cString: gtk_entry_get_text_wrapper(gtk_entry_cast(titleEntry)))
    
    var start: GtkTextIter = GtkTextIter()
    var end: GtkTextIter = GtkTextIter()
    gtk_text_buffer_get_start_iter(textBuffer, &start)
    gtk_text_buffer_get_end_iter(textBuffer, &end)
    
    let contentPtr = gtk_text_buffer_get_text(textBuffer, &start, &end, 0)
    let content = String(cString: contentPtr!)
    g_free(contentPtr)
    
    // Save the note using the GUID-based API
    let noteId: String?
    if currentNoteId.isEmpty {
        // Create new note
        noteId = notesManager.saveNote(id: nil, title: title, content: content)
    } else {
        // Update existing note
        noteId = notesManager.saveNote(id: currentNoteId, title: title, content: content)
    }
    
    if let noteId = noteId {
        currentNoteId = noteId
        loadNotesList()
        print("✅ Note saved: \(title)")
    } else {
        print("❌ Failed to save note")
    }
}

nonisolated(unsafe) let deleteNoteCallback: @convention(c) (UnsafeMutablePointer<GtkButton>?, gpointer?) -> Void = { button, userData in
    guard !currentNoteId.isEmpty else { return }
    
    let success = notesManager.deleteNote(id: currentNoteId)
    if success {
        currentNoteId = ""
        gtk_entry_set_text_wrapper(gtk_entry_cast(titleEntry), "")
        gtk_text_buffer_set_text(textBuffer, "", -1)
        loadNotesList()
        print("✅ Note deleted")
    } else {
        print("❌ Failed to delete note")
    }
}

func loadNotesList() {
    // Clear existing items
    let child = gtk_widget_get_first_child(notesListBox)
    var currentChild = child
    while currentChild != nil {
        let nextChild = gtk_widget_get_next_sibling(currentChild)
        gtk_list_box_remove(gtk_list_box_cast(notesListBox), currentChild)
        currentChild = nextChild
    }
    
    // Load notes with their IDs
    let notes = notesManager.getAllNotesWithIds()
    for note in notes {
        let button = gtk_button_new_with_label(note.title)
        
        // Store note ID as data instead of title
        g_object_set_data_full(g_object_cast(button), "note-id",
                              g_strdup(note.id),
                              g_free_destroy_notify)
        
        // Connect click signal
        g_signal_connect_data(button, "clicked",
                             unsafeBitCast(noteSelectedCallback, to: GCallback.self),
                             nil, nil, G_CONNECT_DEFAULT)
        
        gtk_list_box_append(gtk_list_box_cast(notesListBox), button)
    }
}

nonisolated(unsafe) let noteSelectedCallback: @convention(c) (UnsafeMutablePointer<GtkButton>?, gpointer?) -> Void = { button, userData in
    let noteIdPtr = g_object_get_data(g_object_cast(button), "note-id")
    guard let noteIdPtr = noteIdPtr else { return }
    
    let noteId = String(cString: noteIdPtr.assumingMemoryBound(to: CChar.self))
    currentNoteId = noteId
    
    if let note = notesManager.loadNote(id: noteId) {
        gtk_entry_set_text_wrapper(gtk_entry_cast(titleEntry), note.title)
        gtk_text_buffer_set_text(textBuffer, note.content, -1)
    }
}

// Define the activate callback
nonisolated(unsafe) let activateCallback: @convention(c) (UnsafeMutablePointer<GtkApplication>?, gpointer?) -> Void = { app, userData in
    // Create main window
    let window = gtk_application_window_new(app)
    gtk_window_set_title(gtk_window_cast(window), "Notes Manager")
    gtk_window_set_default_size(gtk_window_cast(window), 800, 600)
    
    // Create header bar
    let headerBar = gtk_header_bar_new()
    gtk_header_bar_set_show_title_buttons(gtk_header_bar_cast(headerBar), bool_to_gboolean(true))
    gtk_header_bar_set_title_widget(gtk_header_bar_cast(headerBar), 
                                   gtk_label_new("Notes Manager"))
    gtk_window_set_titlebar(gtk_window_cast(window), headerBar)
    
    // Create main vertical box
    let mainBox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 10)
    gtk_widget_set_margin_top(mainBox, 20)
    gtk_widget_set_margin_bottom(mainBox, 20)
    gtk_widget_set_margin_start(mainBox, 20)
    gtk_widget_set_margin_end(mainBox, 20)
    
    // Create horizontal paned container
    let paned = gtk_paned_new(GTK_ORIENTATION_HORIZONTAL)
    
    // Left panel - Notes list
    let leftBox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 10)
    gtk_widget_set_size_request(leftBox, 250, -1)
    
    // Notes list label
    let notesLabel = gtk_label_new(nil)
    gtk_label_set_markup(gtk_label_cast(notesLabel), "<b>Notes</b>")
    gtk_widget_set_halign(notesLabel, GTK_ALIGN_START)
    gtk_box_append(gtk_box_cast(leftBox), notesLabel)
    
    // Scrolled window for notes list
    let notesScrolled = gtk_scrolled_window_new()
    gtk_scrolled_window_set_policy(gtk_scrolled_window_cast(notesScrolled), 
                                  GTK_POLICY_NEVER, GTK_POLICY_AUTOMATIC)
    gtk_widget_set_vexpand(notesScrolled, bool_to_gboolean(true))
    
    // Notes list box
    notesListBox = gtk_list_box_new()
    gtk_scrolled_window_set_child(gtk_scrolled_window_cast(notesScrolled), notesListBox)
    gtk_box_append(gtk_box_cast(leftBox), notesScrolled)
    
    // Right panel - Note editor
    let rightBox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 10)
    
    // Title entry
    titleEntry = gtk_entry_new()
    gtk_entry_set_placeholder_text(gtk_entry_cast(titleEntry), "Note title...")
    gtk_box_append(gtk_box_cast(rightBox), titleEntry)
    
    // Text view for content
    let textScrolled = gtk_scrolled_window_new()
    gtk_scrolled_window_set_policy(gtk_scrolled_window_cast(textScrolled), 
                                  GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
    gtk_widget_set_vexpand(textScrolled, bool_to_gboolean(true))
    
    let textView = gtk_text_view_new()
    textBuffer = gtk_text_view_get_buffer(gtk_text_view_cast(textView))
    gtk_text_buffer_set_text(textBuffer, "Start writing your note here...", -1)
    gtk_text_view_set_left_margin(gtk_text_view_cast(textView), 10)
    gtk_text_view_set_right_margin(gtk_text_view_cast(textView), 10)
    gtk_text_view_set_top_margin(gtk_text_view_cast(textView), 10)
    gtk_text_view_set_bottom_margin(gtk_text_view_cast(textView), 10)
    
    gtk_scrolled_window_set_child(gtk_scrolled_window_cast(textScrolled), textView)
    gtk_box_append(gtk_box_cast(rightBox), textScrolled)
    
    // Button box
    let buttonBox = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10)
    gtk_widget_set_halign(buttonBox, GTK_ALIGN_END)
    
    // Buttons
    let newButton = gtk_button_new_with_label("New")
    let saveButton = gtk_button_new_with_label("Save")
    let deleteButton = gtk_button_new_with_label("Delete")
    
    // Add CSS classes for styling
    gtk_widget_add_css_class(saveButton, "suggested-action")
    gtk_widget_add_css_class(deleteButton, "destructive-action")
    
    gtk_box_append(gtk_box_cast(buttonBox), newButton)
    gtk_box_append(gtk_box_cast(buttonBox), saveButton)
    gtk_box_append(gtk_box_cast(buttonBox), deleteButton)
    
    // Connect button signals
    g_signal_connect_data(newButton, "clicked",
                         unsafeBitCast(newNoteCallback, to: GCallback.self),
                         nil, nil, G_CONNECT_DEFAULT)
    g_signal_connect_data(saveButton, "clicked", 
                         unsafeBitCast(saveNoteCallback, to: GCallback.self),
                         nil, nil, G_CONNECT_DEFAULT)
    g_signal_connect_data(deleteButton, "clicked",
                         unsafeBitCast(deleteNoteCallback, to: GCallback.self),
                         nil, nil, G_CONNECT_DEFAULT)
    
    gtk_box_append(gtk_box_cast(rightBox), buttonBox)
    
    // Pack panels into paned container
    gtk_paned_set_start_child(gtk_paned_cast(paned), leftBox)
    gtk_paned_set_end_child(gtk_paned_cast(paned), rightBox)
    gtk_paned_set_position(gtk_paned_cast(paned), 250)
    
    // Pack everything
    gtk_box_append(gtk_box_cast(mainBox), paned)
    gtk_window_set_child(gtk_window_cast(window), mainBox)
    
    // Show the window
    gtk_window_present(gtk_window_cast(window))
    
    // Load existing notes
    loadNotesList()
    
    print("✅ Notes Manager window created successfully!")
}

// Set up the activate signal
g_signal_connect_data(app, "activate", 
                     unsafeBitCast(activateCallback, to: GCallback.self),
                     nil, nil, G_CONNECT_DEFAULT)

// Run the application
let status = g_application_run(g_application_cast(app), 0, nil)

// Cleanup
g_object_unref(app)
exit(Int32(status))
