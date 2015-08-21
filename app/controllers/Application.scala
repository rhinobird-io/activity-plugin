package controllers

import play.api.libs.json._
import play.api.mvc._

class Application extends Controller {

  def index = Action {
    Ok(Json.obj("msg" -> "Hello World"))
  }

}
