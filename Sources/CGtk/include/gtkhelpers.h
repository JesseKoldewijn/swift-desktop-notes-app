//
// GTK Helper functions to work around macro limitations in Swift
//

#ifndef GTKHELPERS_H
#define GTKHELPERS_H

#include <gtk/gtk.h>

// Helper functions for GTK macros that aren't available in Swift

static inline GtkWidget *gtk_widget_cast(void *widget)
{
    return GTK_WIDGET(widget);
}

static inline GtkWindow *gtk_window_cast(void *widget)
{
    return GTK_WINDOW(widget);
}

static inline GtkBox *gtk_box_cast(void *widget)
{
    return GTK_BOX(widget);
}

static inline GtkEntry *gtk_entry_cast(void *widget)
{
    return GTK_ENTRY(widget);
}

static inline GtkTextView *gtk_text_view_cast(void *widget)
{
    return GTK_TEXT_VIEW(widget);
}

static inline GtkListBox *gtk_list_box_cast(void *widget)
{
    return GTK_LIST_BOX(widget);
}

static inline GtkPaned *gtk_paned_cast(void *widget)
{
    return GTK_PANED(widget);
}

static inline GtkScrolledWindow *gtk_scrolled_window_cast(void *widget)
{
    return GTK_SCROLLED_WINDOW(widget);
}

static inline GtkHeaderBar *gtk_header_bar_cast(void *widget)
{
    return GTK_HEADER_BAR(widget);
}

static inline GtkLabel *gtk_label_cast(void *widget)
{
    return GTK_LABEL(widget);
}

static inline GtkButton *gtk_button_cast(void *widget)
{
    return GTK_BUTTON(widget);
}

static inline GApplication *g_application_cast(void *app)
{
    return G_APPLICATION(app);
}

static inline GObject *g_object_cast(void *object)
{
    return G_OBJECT(object);
}

static inline gboolean bool_to_gboolean(bool value)
{
    return value ? TRUE : FALSE;
}

// GTK entry functions (these are real functions, not macros, but include for completeness)
static inline void gtk_entry_set_text_wrapper(GtkEntry *entry, const char *text)
{
    gtk_editable_set_text(GTK_EDITABLE(entry), text);
}

static inline const char *gtk_entry_get_text_wrapper(GtkEntry *entry)
{
    return gtk_editable_get_text(GTK_EDITABLE(entry));
}

// GDestroyNotify wrapper for g_free
static inline void g_free_destroy_notify(gpointer data)
{
    g_free(data);
}

#endif // GTKHELPERS_H
