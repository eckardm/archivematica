# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations
import main.models


class Migration(migrations.Migration):

    dependencies = [
        ('main', '0017_update_seigfried'),
    ]

    operations = [
        migrations.AlterField(
            model_name='file',
            name='currentlocation',
            field=main.models.BlobTextField(null=True, db_column=b'currentLocation'),
            preserve_default=True,
        ),
        migrations.AlterField(
            model_name='file',
            name='originallocation',
            field=main.models.BlobTextField(db_column=b'originalLocation'),
            preserve_default=True,
        ),
    ]
