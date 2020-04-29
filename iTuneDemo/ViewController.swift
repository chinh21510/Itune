//
//  ViewController.swift
//  iTuneDemo
//
//  Created by Chinh Dinh on 4/28/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    var songs = [Song]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        requestSongs()
    }
    
    func setupUI() {
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SongCell", bundle: nil), forCellReuseIdentifier: "SongCell")
        tableView.rowHeight = 80
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell") as! SongCell
        let song = songs[indexPath.row]
        let url = URL(string: song.artwork)
        let data = try? Data(contentsOf: url!)
        
        cell.artWorkImageView.layer.cornerRadius = 8.0
        cell.artWorkImageView.layer.masksToBounds = true
        
        cell.artWorkImageView.image = UIImage(data: data!)
        cell.nameLabel.text = song.name
        cell.artistNameLabel.text = song.artistName
        
        return cell
    }
    
    func requestSongs() {
        let url = URL(string: "https://rss.itunes.apple.com/api/v1/vn/apple-music/new-releases/all/50/explicit.json")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            let json = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
            let feed = json["feed"] as! [String: Any]
            let results = feed["results"] as! [[String: Any]]
            
            var songs = [Song]()
            for result in results {
                let artistName = result["artistName"] as! String
                let name = result["name"] as! String
                let artwork = result["artworkUrl100"] as! String
                let song = Song(artistName: artistName, name: name, artwork: artwork)
                songs.append(song)
            }
            
            self.songs = songs
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
}

