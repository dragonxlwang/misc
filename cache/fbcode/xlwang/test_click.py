import click

@click.command()
@click.option("-a", type=str)
def main(a: str):
    print(a)


if __name__ == "__main__":
    main()
