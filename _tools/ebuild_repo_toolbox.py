#!/usr/bin/env python3
# Copyright 2016-2018 Jan Chren (rindeal) <dev.rindeal@gmail.com>
# Distributed under the terms of the GNU General Public License v2

import os

import portage
import portage.dbapi
import portage.dbapi.porttree
import portage.dbapi.vartree


class EbuildRepoToolbox:

	@staticmethod
	def locate_repo_root(start_dir=None):
		d = os.getcwd() if start_dir is None else start_dir

		while d and d != "/":
			with os.scandir(d) as entries:
				for entry in entries:
					if entry.is_dir() and entry.name == "profiles":
						repo_name_path = os.path.join(entry.path, "repo_name")
						if os.path.exists(repo_name_path):
							return d
			d = os.path.dirname(d)

		return None

	@classmethod
	def setup_working_environment(cls, repo_dir=None):
		if repo_dir is None:
			repo_dir = cls.locate_repo_root()

		os.chdir(repo_dir)
		os.environ["PORTDIR_OVERLAY"] = repo_dir

	@classmethod
	def get_db(cls) -> dict:
		return portage.db[portage.root]

	@classmethod
	def get_portagetree(cls) -> portage.dbapi.porttree.portagetree:
		return cls.get_db()['porttree']

	@classmethod
	def get_vartree(cls) -> portage.dbapi.vartree.vartree:
		return cls.get_db()['vartree']
