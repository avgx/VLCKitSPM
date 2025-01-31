import UIKit

extension PlayerWrapper: VLCCustomDialogRendererProtocol {
    public func showError(withTitle error: String, message: String) {
        //TODO: возможно стоит передавать и message вырезая из него "VLC is" или "VLC" и переводя
        guard mediaPlayer?.media != nil else { return }
        
        var e: PlayerWrapper.VideoState.Error = .other("unknown")
        if (error == "Codec not supported") {
            //VLC could not decode the format "jpeg" (JPEG)
            e = .codec_not_supported
        } else if error == "Your input can't be opened" {
            /// VLC is unable to open the MRL 'http://root:root@192.168.1.85:8000/live/media/format=mp4'. Check the log for details.
            e = .unable_to_open
        } else {
            e = .other(error)
        }
        
        self.error = e
        self.state = .stopped(.error) //TODO: не перекрывает ли это реальную причину?
    }
    
    public func showLogin(withTitle title: String, message: String, defaultUsername username: String?, askingForStorage: Bool, withReference reference: NSValue) {
        //print("VideoView showLogin")
    }
    
    public func showQuestion(withTitle title: String, message: String, type questionType: VLCDialogQuestionType, cancel cancelString: String?, action1String: String?, action2String: String?, withReference reference: NSValue) {
        
        if let action1Ttile = action1String, "Accept certificate temporarily" == action1Ttile {
            self.dialogProvider?.postAction(1, forDialogReference: reference)
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let cancelTitle = cancelString {
            alertController.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { [weak self] action in
                self?.dialogProvider?.postAction(3, forDialogReference: reference)
            }))
        }
        if let action1Ttile = action1String {
            let confirmAction = UIAlertAction(title: action1Ttile, style: .default, handler: { [weak self] action in
                self?.dialogProvider?.postAction(1, forDialogReference: reference)
            })
            alertController.addAction(confirmAction)
            alertController.preferredAction = confirmAction
        }
        
        if let action2Title = action2String {
            alertController.addAction(UIAlertAction(title: action2Title, style: .default, handler: {[weak self] action in
                self?.dialogProvider?.postAction(2, forDialogReference: reference)
            }))
        }
        if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
            let presentingController = rootViewController.presentedViewController ?? rootViewController
            presentingController.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func showProgress(withTitle title: String, message: String, isIndeterminate: Bool, position: Float, cancel cancelString: String?, withReference reference: NSValue) {
    }
    
    public func updateProgress(withReference reference: NSValue, message: String?, position: Float) {

    }
    
    public func cancelDialog(withReference reference: NSValue) {
        if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
            let presentingController = rootViewController.presentedViewController ?? rootViewController
            presentingController.dismiss(animated: true, completion: nil)
        }
    }
}
