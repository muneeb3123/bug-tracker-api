require 'io/wait'

class Reline::GeneralIO
  RESET_COLOR = '' # Do not send color reset sequence

  def self.reset(encoding: nil)
    @@pasting = false
    if encoding
      @@encoding = encoding
    elsif defined?(@@encoding)
      remove_class_variable(:@@encoding)
    end
  end

  def self.encoding
    if defined?(@@encoding)
      @@encoding
    elsif RUBY_PLATFORM =~ /mswin|mingw/
      Encoding::UTF_8
    else
      Encoding::default_external
    end
  end

  def self.win?
    false
  end

  def self.set_default_key_bindings(_)
  end

  @@buf = []
  @@input = STDIN

  def self.input=(val)
    @@input = val
  end

  def self.with_raw_input
    yield
  end

  def self.getc(_timeout_second)
    unless @@buf.empty?
      return @@buf.shift
    end
    c = nil
    loop do
      Reline.core.line_editor.handle_signal
      result = @@input.wait_readable(0.1)
      next if result.nil?
      c = @@input.read(1)
      break
    end
    c&.ord
  end

  def self.ungetc(c)
    @@buf.unshift(c)
  end

  def self.get_screen_size
    [24, 80]
  end

  def self.cursor_pos
    Reline::CursorPos.new(1, 1)
  end

  def self.hide_cursor
  end

  def self.show_cursor
  end

  def self.move_cursor_column(val)
  end

  def self.move_cursor_up(val)
  end

  def self.move_cursor_down(val)
  end

  def self.erase_after_cursor
  end

  def self.scroll_down(val)
  end

  def self.clear_screen
  end

  def self.set_screen_size(rows, columns)
  end

  def self.set_winch_handler(&handler)
  end

  @@pasting = false

  def self.in_pasting?
    @@pasting
  end

  def self.prep
  end

  def self.deprep(otio)
  end
end
