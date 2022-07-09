import js.html.MouseEvent;
import js.html.DocumentFragment;
import js.Browser;

using dectiss.parser.Parser;

class Test {
	static function main() {
		var document = Browser.window.document;
		var fragment = new DocumentFragment();

		var compile = document.createButtonElement();
		compile.innerText = "compile";
		fragment.appendChild(compile);

		fragment.appendChild(document.createBRElement());

		var input = document.createTextAreaElement();
		input.cols = 80;
		input.rows = 50;
		fragment.appendChild(input);

		var result = document.createTextAreaElement();
		result.cols = 80;
		result.rows = 50;
		fragment.appendChild(result);

		document.body.appendChild(fragment);

		try {
			input.value = Browser.getLocalStorage().getItem("code");
		} catch (e:Dynamic) {}

		compile.addEventListener("click", (e:MouseEvent) -> {
			result.value = TestExpression.parse(input.value);
			return;
		});

		input.addEventListener("input", (e:Dynamic) -> {
			Browser.getLocalStorage().setItem("code", e.target.value);
			return;
		});
	}
}
