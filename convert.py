import pandas as pd
import re
import polib
import os

def to_gettext(sheet, page):
	print(f"read {sheet}/{page}")

	data = pd.read_excel(sheet, sheet_name=page)

	output_dir=re.sub("[^a-z0-9]+", "_", page.lower())

	source_text_col = 'default'
	key_col = 'Identifier'
	comment_col = 'Remarks'
	source_lang_code = 'en_US'

	mapping = {
		"default": "en_US",
		"eng enc ena enz eni ens enj enb enl ent enw": "en_GB",
		"by": "be",
		# cs
		# da
		# de
		# el
		# eo
		# es
		"esm esn esg esc esa esd esv eso esr ess esf esl esy esz esb ese esh esi esu": "es-MX",
		# fi
		# fr
		# hr
		# hu
		# it
		"ja jp": "ja",
		# ko
		# nl
		"no nb": "no",
		# pl
		"pt": "pt-BR",
		"ptg": "pt",
		# ro
		# ru
		# sr
		# sv
		# tr
		# uk
		# bg
		# ba
	}
	ignored_cols = ['Identifier', 'Remarks', 'Filter']

	lang_cols = [col for col in data.columns if col not in ignored_cols]

	if not os.path.exists(output_dir):
		os.makedirs(output_dir)
		print(f"mkdir {output_dir}")

	for lang_col_name in lang_cols:
		output_lang_code = mapping[lang_col_name] if lang_col_name in mapping else lang_col_name

		print(f"  in: {lang_col_name}")

		po_trans = polib.POFile()
		po_trans.metadata = {
			'Project-Id-Version': '1.0',
			'Content-Type': 'text/plain; charset=utf-8',
			'Language': output_lang_code,
			'HeaderCode': lang_col_name,
		}

		for _, row in data.iterrows():
			entry = polib.POEntry(
				msgid=str(row[key_col]),
				msgstr=str(row[lang_col_name]) if pd.notna(row[lang_col_name]) else '',
				tcomment=str(row[comment_col]) if pd.notna(row[comment_col]) else ''
			)
			po_trans.append(entry)

		po_trans.save(os.path.join(output_dir, f"{output_lang_code}.po"))
		print(f"  out: {output_lang_code}")

def to_csv(sheet, page):
	print(f"read {sheet}/{page}")

	data = pd.read_excel(sheet, sheet_name=page)

	output=re.sub("[^a-z0-9]+", "_", page.lower())

	data.to_csv(f"{output}.csv", index=False)

	print(f"out {output}.csv")

if __name__ == "__main__":
	sheet="./GZDoom and Raze Strings.xlsx"

	to_gettext(sheet, "Common")
	to_gettext(sheet, "GZDoom Engine Strings")
	to_gettext(sheet, "GZDoom Game Strings")
	to_gettext(sheet, "Chex Quest 3")
	to_gettext(sheet, "Harmony")
	to_gettext(sheet, "Hacx")
	to_csv(sheet, "Macros")
	# to_gettext(sheet, "Raze")
	# to_gettext(sheet, "Unused content")
