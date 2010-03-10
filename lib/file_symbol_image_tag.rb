module FileSymbolImageTag
  # returns symbols for directories of files, depending on their extension
  def symbol_for element
    return image_tag('file_type_symbols/folder.gif') if element[:type] == 'directory'

    extension = element[:extension].downcase if element[:extension]

    icon = case extension
      when 'exe'  then 'disk.png'

      when 'txt'  then 'text.png'
      when 'php'  then 'php.png'
      when 'js'   then 'script.gif'
      when 'rb'   then 'ruby.png'
      when 'css'  then 'css.png'

      when 'cfg'  then 'gear.png'
      when 'dat'  then 'gear.png'

      when 'pdf'  then 'pdf.gif'

      when 'font' then 'font.gif'
      when 'ttf'  then 'font.gif'
      when 'pfa'  then 'font.gif'
      when 'pfb'  then 'font.gif'

      when 'doc'  then 'word.png'
      when 'xls'  then 'excel.png'
      when 'ppt'  then 'powerpoint.png'

      when 'zip'  then 'zip.gif'
      when 'tgz'  then 'zip.gif'
      when 'tar'  then 'zip.gif'

      when 'html' then 'html.png'

      when 'bmp'  then 'bmp.gif'
      when 'gif'  then 'gif.gif'
      when 'jpg'  then 'jpg.gif'
      when 'jpeg' then 'jpg.gif'
      when 'png'  then 'png.gif'
      when 'ico'  then 'ico.gif'

      when 'fla'  then 'flash.png'
      when 'swf'  then 'flash.png'
      when 'flv'  then 'flash.png'
      when 'rm'   then 'flash.png'

      when 'avi'  then 'media.gif'
      when 'mpeg' then 'media.gif'
      when 'mpg'  then 'media.gif'

      when 'bat'  then 'computer.png'

      when 'enc'  then 'lock.png'

      else 'quest.png'
    end

    return image_tag('file_type_symbols/' + icon)
  end  
end
