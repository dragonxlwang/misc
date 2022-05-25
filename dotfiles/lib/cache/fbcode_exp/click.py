import click


@click.group()
def group():
    pass


@group.command()
@click.option("--hash-type", type=click.Choice(["MD5", "SHA1"], case_sensitive=False))
@click.option("--test_flag", default=True, type=bool)
def c1_tt(hash_type, test_flag):
    click.echo(hash_type)
    click.echo(test_flag)
    print(hash_type)
    pass


if __name__ == "__main__":
    group()
