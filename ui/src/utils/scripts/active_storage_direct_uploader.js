import { DirectUpload } from "@rails/activestorage"

export default class ActiveStorageDirectUploader {
  constructor(file, url, options) {
    this.upload = new DirectUpload(file, url, this)
    this.options = options
  }

  uploadFile(file) {
    return new Promise((resolve, reject) => {
      this.upload.create((error, blob) => {
        if (error) {
          reject(error);
        } else {
          resolve(blob);
        }
      })
    });
  }

  directUploadWillStoreFileWithXHR(request) {
    if (this.options.onProgress) {
      request.upload.addEventListener("progress", event => {
        this.options.onProgress(event);
      });
    }
  }
}