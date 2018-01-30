module TulipHelpers
  def mb_artist_search_path(artist)
    return '' if artist == nil
    return "https://musicbrainz.org/search?query=#{artist.gsub(/[&?=]/, '')}&type=artist&method=indexed"
  end

  def make_release(album)
    artist = album.artists.first
    
    performer = Performer.find_or_initialize_by(old_id: artist.id)
    performer.update_attributes(
      title: artist.title,
      aliases: "#{artist.romaji}, #{artist.aliases}",
      tmp_tags: artist.tagsstr
    )

    release = Release.find_or_initialize_by(old_id: album.id)    
    release.update_attributes(
      performer: performer,
      title: "#{album.year} #{album.title}",
      aliases: album.romaji,
      tmp_tags: album.tagsstr,
      old_id: album.id
    )
    # TODO: move cover/write property/etc

    return release
  end

  def make_record(release, t) # t for track
    yearmonth = Date.today.strftime("%Y%m")
    ympath = File.join($library_path, "lib", yearmonth)
    release_path = File.join(ympath, release.id.to_s)

    if t.rating >= 7
      Dir.mkdir(ympath) unless Dir.exist?(ympath)
      Dir.mkdir(release_path) unless Dir.exist?(release_path)
      extension = t.filename.downcase.gsub(/.*\.([^\.]*)/, "\\1")
      # create unique newfilename
      while File.exist?(File.join(release_path, newfilename = "#{SecureRandom.hex(4)}.#{extension}")) do end
      File.rename(t.full_path, File.join(release_path, newfilename))
  
      record = Record.create(
        release: release,
        original_filename: t.filename,
        filename: newfilename,
        directory: File.join(yearmonth, release.id.to_s),
        rating: (t.rating - 7),
        lyrics: t.lyrics,
        tmp_tags: t.tagsstr,
        old_id: t.id,
        mediainfo: t.mediainfo
      )
    else
      File.delete(t.full_path) rescue nil
    end

    t.status = "processed"
    t.save
  end

  def process_album(album)
    release = make_release(album)
    album.tracks.where.not(status: "processed").each do |t|
      make_record(release, t)
    end
    album.status = "processed"
    album.save
    # Dir.delete(album.full_path)
  end

  def process_track(track)
    release = make_release(track.album)
    record = make_record(release, track)
  end

  def ms2ts(time)
    ms   = time % 1000
    time = time / 1000
    s    = time % 60
    time = time / 60
    m    = time % 60
    time = time / 60
    h    = time
    if h != 0
      return "#{h}:#{'%02d' % m}:#{'%02d' % s}.#{ms/100}"
    elsif m != 0
      return "#{m}:#{'%02d' % s}.#{ms/100}"
    else
      return "0:#{'%02d' % s}.#{ms/100}"
    end
  end

  def mediainfo(info)
    return nil unless info
    return "#{ms2ts(info['dur'])} [#{info['br'].to_i/1000}#{info['brm']} @ #{(info['sr'].to_i/1000.0).round(3)}kHz]"
  end
end
