class Dir
  def Dir.versioned_dirname(base, first_suffix = '_0')
    suffix = nil
    dirname = base
    while File.directory?(dirname)
      suffix = (suffix ? suffix.succ : first_suffix)
      dirname = base + suffix
    end
    return dirname
  end
end