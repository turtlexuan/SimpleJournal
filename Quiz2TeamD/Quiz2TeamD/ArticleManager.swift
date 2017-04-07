//
import UIKit
import CoreData

class ArticleManager {

    static let shared = ArticleManager()

    func save(article: Article) {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let context = appDelegate.persistentContainer.viewContext
        let articleData = ArticleMO(context: context)

        guard
            let graphData = UIImagePNGRepresentation(article.image) as NSData?
            else { return }

        articleData.title = article.title
        articleData.content = article.content
        articleData.image = graphData
        articleData.text = article.content
        articleData.graph = graphData

        appDelegate.saveContext()
    }

    typealias RequireArticleCompletion = ([Article]?, Error?) -> Void
    func fetch(_ complettion: RequireArticleCompletion) {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let articleRequest: NSFetchRequest<ArticleMO> = ArticleMO.fetchRequest()
        var articleList: [Article] = []

        do {
            let articleData = try context.fetch(articleRequest)
            for data in articleData {

                guard
<<<<<<< HEAD
                    let graphData = data.image,
                    let title = data.title,
                    let text = data.content,
=======
                    let graphData = data.graph,
                    let title = data.title,
                    let text = data.text,
>>>>>>> 8bbccc722766ee7f0a48ff03f1d89f24125a0229
                    let graph = UIImage(data: graphData as Data)
                    else { return }
                let article = Article(title: title, content: text, image: graph)
                articleList.append(article)
            }
            complettion(articleList, nil)
        } catch {

            complettion(nil, error)

        }
    }
<<<<<<< HEAD
    
    func update(_ index: Int) {
        
        
        
    }
=======
>>>>>>> 8bbccc722766ee7f0a48ff03f1d89f24125a0229

}
