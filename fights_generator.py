class Wrestler:
    def __init__(self, full_name, weight_category, wrestling_style):
        self.full_name = full_name
        self.weight_category = weight_category
        self.wrestling_style = wrestling_style

    def __repr__(self):
        return f"{self.full_name} ({self.weight_category}, {self.wrestling_style})"


def is_power_of_two(n):
    if n <= 0:
        return False
    return (n & (n - 1)) == 0


def largest_power_of_two_less_than_or_equal_to(n):
    if n < 1:
        return 0
    power = 1
    while power * 2 <= n:
        power *= 2
    return power


def difference_with_largest_power_of_two(n):
    if n < 1:
        return "Input should be a positive integer."
    largest_power = largest_power_of_two_less_than_or_equal_to(n)
    return n - largest_power


def fights_generator(wrestlers):
    """Generates fights between wrestlers."""
    wrestlers_number = len(wrestlers)
    fights = []

    if is_power_of_two(wrestlers_number):
        print("The number of wrestlers is a power of 2.")
        for i in range(0, wrestlers_number, 2):
            fights.append((wrestlers[i], wrestlers[i + 1]))
    else:
        extra_fights = difference_with_largest_power_of_two(wrestlers_number)
        for i in range(0, extra_fights * 2, 2):
            fights.append((wrestlers[i], wrestlers[i + 1]))

    return fights


# Example usage:
wrestlers_list = [
    Wrestler("John Doe", "Heavyweight", "Freestyle"),
    Wrestler("Alex Smith", "Middleweight", "Greco-Roman"),
    Wrestler("David Brown", "Lightweight", "Freestyle"),
    Wrestler("Chris Johnson", "Heavyweight", "Greco-Roman"),
    Wrestler("Michael White", "Middleweight", "Freestyle"),
    Wrestler("James Black", "Lightweight", "Greco-Roman"),
    Wrestler("Robert Green", "Heavyweight", "Freestyle"),
    Wrestler("Daniel Adams", "Middleweight", "Greco-Roman"),
    Wrestler("Chris Johnson", "Heavyweight", "Greco-Roman"),
    Wrestler("Michael White", "Middleweight", "Freestyle"),
    Wrestler("James Black", "Lightweight", "Greco-Roman"),
    Wrestler("Robert Green", "Heavyweight", "Freestyle"),
    Wrestler("Daniel Adams", "Middleweight", "Greco-Roman"),
    Wrestler("Michael White", "Middleweight", "Freestyle"),
    Wrestler("James Black", "Lightweight", "Greco-Roman"),
    Wrestler("Robert Green", "Heavyweight", "Freestyle"),
]


fights = fights_generator(wrestlers_list)

# Display fights
for fight in fights:
    print(f"{fight[0]} vs {fight[1]}")
